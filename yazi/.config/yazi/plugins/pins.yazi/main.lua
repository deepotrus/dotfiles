--- @since 26.9.1
-- pins: pin files/folders to the top of their directory, like nemo.
-- Needs `sort_by = "custom"` in yazi.toml. Pins live in a plain text file, one absolute path per line.

local M = {}

local DATA_DIR = (os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share") .. "/yazi"
local DEFAULT_FILE = DATA_DIR .. "/pins.txt"

local function split(path) return path:match("^(.*)/([^/]+)$") end

-- state.pins = { [dir] = { [name] = true } }
local function load_pins(state)
	state.pins = {}
	local f = io.open(state.file, "r")
	if not f then
		return
	end
	for line in f:lines() do
		local dir, name = split(line)
		if dir then
			dir = dir == "" and "/" or dir
			state.pins[dir] = state.pins[dir] or {}
			state.pins[dir][name] = true
		end
	end
	f:close()
end

local function save_pins(state)
	local f, err = io.open(state.file, "w")
	if not f then
		return ya.notify { title = "Pins", content = "Cannot write " .. state.file .. ": " .. tostring(err), timeout = 3, level = "error" }
	end
	for dir, names in pairs(state.pins) do
		for name in pairs(names) do
			f:write((dir == "/" and "" or dir) .. "/" .. name .. "\n")
		end
	end
	f:close()
end

local function find_folder(url)
	local tab = cx.active
	local folders = { tab.current, tab.parent, tab.preview.folder }
	for i = 1, 3 do
		local folder = folders[i]
		if folder and folder.cwd == url then
			return folder
		end
	end
end

-- Push ranks for the pinned entries of `folder`; `unpinned` resets one name back to rank 0.
local function apply(state, folder, unpinned)
	local names = state.pins[tostring(folder.cwd)]
	if not names and not unpinned then
		return
	end

	local ranks, any = {}, false
	for _, file in ipairs(folder.files) do
		local name = file.name
		if names and names[name] then
			ranks[file.url.key], any = -1, true
		elseif name == unpinned then
			ranks[file.url.key], any = 0, true
		end
	end
	if any then
		ya.emit("update_files", { op = fs.op("rank", { url = folder.cwd, ranks = ranks }) })
	end
end

local toggle = ya.sync(function(state)
	local h = cx.active.current.hovered
	if not h then
		return
	end

	local dir, name = split(tostring(h.url))
	dir = dir == "" and "/" or dir
	state.pins[dir] = state.pins[dir] or {}
	local pinned = not state.pins[dir][name]
	state.pins[dir][name] = pinned or nil
	if next(state.pins[dir]) == nil then
		state.pins[dir] = nil
	end
	save_pins(state)

	apply(state, cx.active.current, not pinned and name or nil)
	ya.notify { title = "Pins", content = (pinned and "Pinned: " or "Unpinned: ") .. name, timeout = 2 }
end)

function M:setup(opts)
	self.file = opts and opts.file or DEFAULT_FILE
	load_pins(self)

	ps.sub("load", function(body)
		local folder = find_folder(body.url)
		if folder then
			apply(self, folder)
		end
	end)

	-- Show a pin marker after the name of pinned entries.
	Entity:children_add(function(entity)
		local dir, name = split(tostring(entity._file.url))
		local names = dir and self.pins[dir == "" and "/" or dir]
		return names and names[name] and ui.Span(" 📌") or ""
	end, 4500)
end

local get_file = ya.sync(function(state) return state.file end)

function M:entry()
	fs.create("dir_all", Url(get_file():match("^(.*)/[^/]*$")))
	toggle()
end

return M
