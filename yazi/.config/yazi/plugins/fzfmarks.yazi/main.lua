--- @since 25.5.31
-- fzfmarks: unlimited bookmarks, browsed and filtered with fzf.
-- Bookmarks live in a plain TSV file (name<TAB>path), one per line, in the order you keep them.

local M = {}

local DATA_DIR = (os.getenv("XDG_DATA_HOME") or os.getenv("HOME") .. "/.local/share") .. "/yazi"
local DEFAULT_FILE = DATA_DIR .. "/bookmarks.tsv"

local get_opts = ya.sync(function(state) return { file = state.file or DEFAULT_FILE } end)

local get_target = ya.sync(function(_, use_hovered)
	local h = cx.active.current.hovered
	if use_hovered and h then
		return tostring(h.url)
	end
	return tostring(cx.active.current.cwd)
end)

local function notify(msg, level)
	ya.notify { title = "Bookmarks", content = msg, timeout = 3, level = level or "info" }
end

-- Single-quote a string for sh.
local function sq(s) return "'" .. s:gsub("'", "'\\''") .. "'" end

local function read_lines(file)
	local lines, f = {}, io.open(file, "r")
	if f then
		for line in f:lines() do
			if line ~= "" then
				lines[#lines + 1] = line
			end
		end
		f:close()
	end
	return lines
end

local function add(file, use_hovered)
	local path = get_target(use_hovered)
	for _, line in ipairs(read_lines(file)) do
		if line:match("\t(.*)$") == path then
			return notify("Already bookmarked: " .. path, "warn")
		end
	end

	local name, event = ya.input {
		title = "Bookmark name:",
		value = path:match("([^/]+)/?$") or path,
		pos = { "top-center", y = 3, w = 60 },
		position = { "top-center", y = 3, w = 60 },
	}
	if event ~= 1 or name == "" then
		return
	end
	name = name:gsub("\t", " ")

	local f, err = io.open(file, "a")
	if not f then
		return notify("Cannot write " .. file .. ": " .. tostring(err), "error")
	end
	f:write(name .. "\t" .. path .. "\n")
	f:close()
	notify("Added: " .. name)
end

local function jump(file)
	if #read_lines(file) == 0 then
		return notify("No bookmarks yet, add one first", "warn")
	end

	local qf = sq(file)
	local list = "cat -- " .. qf
	local editor = os.getenv("VISUAL") or os.getenv("EDITOR") or "vi"
	local delete = string.format(
		"t=$(mktemp) && grep -vxF -- {} %s > \"$t\"; mv -- \"$t\" %s",
		qf, qf
	)

	local _permit = (ui.hide or ya.hide)()
	local child, err = Command("fzf")
		:env("FZF_DEFAULT_COMMAND", list)
		:arg({
			"--delimiter=\t",
			"--with-nth=1",
			"--layout=reverse",
			"--tiebreak=index",
			"--prompt=bookmark> ",
			"--header=enter: cd | ctrl-t: new tab | ctrl-d: delete | ctrl-e: edit file",
			"--expect=ctrl-t",
			"--preview=printf '\\033[1;34m%s\\033[0m\\n\\n' {-1}; ls -lA --group-directories-first --color=always -- {-1} 2>&1",
			"--preview-window=right,50%",
			"--bind=ctrl-d:execute-silent(" .. delete .. ")+reload(" .. list .. ")",
			"--bind=ctrl-e:execute(" .. editor .. " " .. qf .. ")+reload(" .. list .. ")",
		})
		:stdin(Command.INHERIT)
		:stdout(Command.PIPED)
		:stderr(Command.INHERIT)
		:spawn()
	if not child then
		return notify("Failed to start fzf: " .. tostring(err), "error")
	end

	local output = child:wait_with_output()
	if not output or not output.status.success then
		return -- cancelled (esc / ctrl-c)
	end

	local key, line = output.stdout:match("^([^\n]*)\n([^\n]*)")
	local path = line and line:match("\t(.*)$")
	if not path or path == "" then
		return
	end

	local cha = fs.cha(Url(path))
	if not cha then
		return notify("Path no longer exists: " .. path, "error")
	end

	if key == "ctrl-t" then
		ya.emit("tab_create", { cha.is_dir and path or path:match("^(.*)/[^/]*$") })
	elseif cha.is_dir then
		ya.emit("cd", { path })
	else
		ya.emit("reveal", { path })
	end
end

function M:setup(opts)
	self.file = opts and opts.file
end

function M:entry(job)
	local action = job.args[1] or "jump"
	local file = get_opts().file
	fs.create("dir_all", Url(file:match("^(.*)/[^/]*$")))
	if action == "add" then
		add(file, false)
	elseif action == "add_hovered" then
		add(file, true)
	else
		jump(file)
	end
end

return M
