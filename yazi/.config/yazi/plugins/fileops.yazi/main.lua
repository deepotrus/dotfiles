--- @since 25.5.31
-- fileops: a small menu of operations on the hovered file (or the selection).
-- Compress to .tar / .tar.gz / .zip, extract an archive, and show file properties (size, md5, sha256, ...).

local M = {}

local MENU = {
	{ on = "t", desc = "Compress to .tar.gz", run = "tar_gz" },
	{ on = "T", desc = "Compress to .tar", run = "tar" },
	{ on = "z", desc = "Compress to .zip", run = "zip" },
	{ on = "x", desc = "Extract archive", run = "extract" },
	{ on = "p", desc = "Properties / checksums", run = "props" },
}

-- Hovered item, selected items and cwd, as plain strings.
local get_state = ya.sync(function()
	local tab = cx.active
	local selected = {}
	for _, f in pairs(tab.selected) do
		selected[#selected + 1] = tostring(f.url)
	end
	local h = tab.current.hovered
	return {
		cwd = tostring(tab.current.cwd),
		hovered = h and tostring(h.url) or nil,
		selected = selected,
	}
end)

local function notify(msg, level)
	ya.notify { title = "File ops", content = msg, timeout = level == "error" and 8 or 3, level = level or "info" }
end

local function dirname(p) return p:match("^(.*)/[^/]*$") or "/" end
local function basename(p) return p:match("([^/]+)/?$") or p end

local function exists(path) return fs.stat(Url(path), false) ~= nil end

-- path, or path_1, path_2, ... if it already exists. A suffix goes before ".ext" for files.
local function unique(path)
	if not exists(path) then
		return path
	end
	local dir, name = dirname(path), basename(path)
	local stem, ext = name:match("^(.+)(%.[^.]+)$") -- "notes.txt" -> "notes", ".txt"; ".hidden" stays whole
	local base = dir .. "/" .. (stem or name)
	ext = ext or ""
	local n = 1
	while exists(string.format("%s_%d%s", base, n, ext)) do
		n = n + 1
	end
	return string.format("%s_%d%s", base, n, ext)
end

-- Run a command and return its trimmed stdout, or nil plus an error message.
local function run(cmd, args, cwd)
	local c = Command(cmd):arg(args)
	if cwd then
		c = c:cwd(cwd)
	end
	local out, err = c:output()
	if not out then
		return nil, cmd .. ": " .. tostring(err)
	end
	if not out.status.success then
		local msg = out.stderr ~= "" and out.stderr or out.stdout
		return nil, cmd .. ": " .. msg:gsub("%s+$", "")
	end
	return (out.stdout:gsub("%s+$", ""))
end

local function ask(title, value)
	local text, event = ya.input {
		title = title,
		value = value,
		pos = { "top-center", y = 3, w = 60 },
		position = { "top-center", y = 3, w = 60 },
	}
	if event ~= 1 or text == "" then
		return nil
	end
	return text
end

local function confirm(title, body)
	return ya.confirm {
		pos = { "center", w = 60, h = 8 },
		title = ui.Line(title),
		body = ui.Text(body or ""),
	}
end

-- Items to work on: the selection if there is one, otherwise the hovered item.
local function targets(st)
	if #st.selected > 0 then
		return st.selected
	end
	return st.hovered and { st.hovered } or {}
end

----------------------------------------------------------------------------
-- Compress
----------------------------------------------------------------------------

local EXT = { tar_gz = ".tar.gz", tar = ".tar", zip = ".zip" }

local function compress(kind, st)
	local items = targets(st)
	if #items == 0 then
		return notify("Nothing hovered or selected", "warn")
	end

	-- Archive members are stored with names relative to their parent folder,
	-- so all items must share one parent.
	local parent = dirname(items[1])
	local names = {}
	for i, p in ipairs(items) do
		if dirname(p) ~= parent then
			return notify("Selected items are in different folders; select items from one folder only", "error")
		end
		names[i] = basename(p)
	end

	local ext = EXT[kind]
	local default = #items == 1 and names[1] or basename(parent)
	local name = ask(string.format("Archive name (%d item%s):", #items, #items == 1 and "" or "s"), default .. ext)
	if not name then
		return
	end
	if not name:find("/", 1, true) then
		name = st.cwd .. "/" .. name
	end
	if exists(name) then
		if not confirm("Overwrite?", name .. " already exists.") then
			return
		end
		local ok, rerr = fs.remove("file", Url(name))
		if not ok then
			return notify("Cannot remove " .. name .. ": " .. tostring(rerr), "error")
		end
	end

	local cmd, args
	if kind == "zip" then
		cmd, args = "zip", { "-r", "-q", "-y", name, "--" }
	else
		cmd, args = "tar", { kind == "tar_gz" and "-czf" or "-cf", name, "--" }
	end
	for _, n in ipairs(names) do
		args[#args + 1] = n
	end

	notify("Compressing " .. #items .. " item(s)...")
	local _, err = run(cmd, args, parent)
	if err then
		return notify(err, "error")
	end
	notify("Created " .. basename(name))
	ya.emit("reveal", { name })
end

----------------------------------------------------------------------------
-- Extract
----------------------------------------------------------------------------

-- Archive types by suffix; the stem is the name without the suffix.
local ARCHIVES = {
	{ ".tar.gz", "tar" },
	{ ".tar.xz", "tar" },
	{ ".tar.bz2", "tar" },
	{ ".tar.zst", "tar" },
	{ ".tgz", "tar" },
	{ ".txz", "tar" },
	{ ".tbz2", "tar" },
	{ ".tar", "tar" },
	{ ".zip", "zip" },
	{ ".jar", "zip" },
}

local function archive_type(path)
	local lower = path:lower()
	for _, a in ipairs(ARCHIVES) do
		if lower:sub(-#a[1]) == a[1] then
			return a[2], basename(path):sub(1, -#a[1] - 1)
		end
	end
end

local function extract(st)
	local items = targets(st)
	if #items == 0 then
		return notify("Nothing hovered or selected", "warn")
	end

	local done, last_dir = 0, nil
	for _, path in ipairs(items) do
		local kind, stem = archive_type(path)
		if not kind then
			notify("Not a supported archive: " .. basename(path), "warn")
		else
			-- Extract into a hidden temporary folder next to the archive, then:
			--   one top-level entry  -> move it next to the archive (no double nesting)
			--   several entries      -> rename the temp folder after the archive
			-- Existing names are never overwritten: a _1, _2, ... suffix is added instead.
			local parent = dirname(path)
			local tmp = unique(parent .. "/." .. stem .. ".extracting")
			fs.create("dir_all", Url(tmp))

			notify("Extracting " .. basename(path) .. "...")
			local _, err
			if kind == "zip" then
				_, err = run("unzip", { "-q", path, "-d", tmp })
			else
				_, err = run("tar", { "-xf", path, "-C", tmp })
			end

			local entries = fs.read_dir(Url(tmp), { limit = 2 }) or {}
			if err and #entries == 0 then
				fs.remove("dir", Url(tmp))
				notify(err, "error")
			else
				local src, dest = tmp, nil
				if #entries == 1 then
					src = tostring(entries[1].url)
					dest = unique(parent .. "/" .. basename(src))
				else
					dest = unique(parent .. "/" .. stem)
				end
				local ok, rerr = fs.rename(Url(src), Url(dest))
				if src ~= tmp then
					fs.remove("dir", Url(tmp))
				end

				if err then
					notify(err .. "\nPartial output kept in " .. (ok and dest or src), "error")
				elseif not ok then
					notify("Extracted, but cannot move to " .. dest .. ": " .. tostring(rerr) .. "\nOutput is in " .. src, "error")
				else
					done = done + 1
					last_dir = dest
				end
			end
		end
	end

	if done > 0 then
		notify(string.format("Extracted %d archive(s)", done))
		ya.emit("reveal", { last_dir })
	end
end

----------------------------------------------------------------------------
-- Properties
----------------------------------------------------------------------------

local function human(bytes)
	local units = { "B", "KiB", "MiB", "GiB", "TiB" }
	local i, n = 1, bytes
	while n >= 1024 and i < #units do
		n, i = n / 1024, i + 1
	end
	return i == 1 and string.format("%d B", bytes) or string.format("%.2f %s", n, units[i])
end

local HOME = os.getenv("HOME") or ""
local function tilde(p)
	if HOME ~= "" and (p == HOME or p:sub(1, #HOME + 1) == HOME .. "/") then
		return "~" .. p:sub(#HOME + 1)
	end
	return p
end

local function first_field(s) return s and s:match("^(%S+)") end

local function props(st)
	local path = st.hovered
	if not path then
		return notify("Nothing hovered", "warn")
	end

	-- %F type, %s size, %A/%a permissions, %U:%G owner, %y mtime, %N quoted name (shows link target)
	local info, err = run("stat", { "-c", "%F\n%s\n%A (%a)\n%U:%G\n%y\n%N", "--", path })
	if not info then
		return notify(err, "error")
	end
	local f = {}
	for line in (info .. "\n"):gmatch("([^\n]*)\n") do
		f[#f + 1] = line
	end
	local ftype, size, perms, owner, mtime, quoted = f[1], tonumber(f[2]), f[3], f[4], f[5], f[6]
	mtime = mtime:gsub("%.%d+", "") -- drop nanoseconds

	local rows = {
		{ "Name", basename(path) },
		{ "Folder", tilde(dirname(path)) },
	}
	if ftype ~= "directory" then
		rows[#rows + 1] = { "Type", ftype .. " - " .. (run("file", { "-b", "--", path }) or "?") }
	end
	if ftype == "symbolic link" then
		rows[#rows + 1] = { "Target", quoted:match("%-> (.*)$") or "?" }
	end

	local cha = fs.stat(Url(path), true)
	if cha and cha.is_dir then
		local du = tonumber(first_field(run("du", { "-sb", "--", path })) or "")
		local count = run("sh", { "-c", 'find "$1" -mindepth 1 | wc -l', "sh", path })
		rows[#rows + 1] = { "Size", du and string.format("%s (%d bytes)", human(du), du) or "?" }
		rows[#rows + 1] = { "Contents", (count or "?") .. " items (recursive)" }
	else
		if cha and ftype == "symbolic link" then
			size = cha.len
		end
		rows[#rows + 1] = { "Size", string.format("%s (%d bytes)", human(size), size) }
	end
	rows[#rows + 1] = { "Permissions", perms }
	rows[#rows + 1] = { "Owner", owner }
	rows[#rows + 1] = { "Modified", mtime }

	if cha and not cha.is_dir then
		if size > 200 * 1024 * 1024 then
			notify("Computing checksums of " .. human(size) .. "...")
		end
		rows[#rows + 1] = { "MD5", first_field(run("md5sum", { "--", path })) or "?" }
		rows[#rows + 1] = { "SHA256", first_field(run("sha256sum", { "--", path })) or "?" }
	end

	local lines = {}
	for _, r in ipairs(rows) do
		lines[#lines + 1] = ui.Line {
			ui.Span(string.format(" %-12s", r[1])):style(ui.Style():fg("blue"):bold()),
			ui.Span(r[2]),
		}:align(ui.Align.LEFT)
	end

	ya.confirm {
		pos = { "center", w = 100, h = #lines + 6 },
		title = ui.Line("Properties: " .. basename(path)),
		body = ui.Text(lines):wrap(ui.Wrap.YES),
	}
end

----------------------------------------------------------------------------

function M:entry(job)
	local action = job.args[1]
	if not action then
		local cands = {}
		for i, m in ipairs(MENU) do
			cands[i] = { on = m.on, desc = m.desc }
		end
		local idx = ya.which { cands = cands }
		if not idx then
			return
		end
		action = MENU[idx].run
	end

	local st = get_state()
	if EXT[action] then
		compress(action, st)
	elseif action == "extract" then
		extract(st)
	elseif action == "props" then
		props(st)
	else
		notify("Unknown action: " .. action, "error")
	end
end

return M
