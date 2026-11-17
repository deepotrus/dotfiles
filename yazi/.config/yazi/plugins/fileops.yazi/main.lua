--- @since 25.5.31
-- fileops: a small menu of operations on the hovered file (or the selection).
-- Compress to .tar / .tar.gz / .zip, extract an archive, show file properties (size, md5, sha256, ...)
-- and compare two files by checksum.

local M = {}

local MENU = {
	{ on = "t", desc = "Compress to .tar.gz", run = "tar_gz" },
	{ on = "T", desc = "Compress to .tar", run = "tar" },
	{ on = "z", desc = "Compress to .zip", run = "zip" },
	{ on = "x", desc = "Extract archive", run = "extract" },
	{ on = "p", desc = "Properties / checksums", run = "props" },
	{ on = "r", desc = "Mark as compare reference", run = "mark_ref" },
	{ on = "c", desc = "Compare (reference or 2 selected)", run = "compare" },
}

-- Hovered item, selected items, cwd and compare reference, as plain strings.
local get_state = ya.sync(function(state)
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
		ref = state.ref,
	}
end)

-- The compare reference lives in the plugin state, so it survives tab switches and folder changes.
local set_ref = ya.sync(function(state, path) state.ref = path end)

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

local ESC = "\27"
local function bold(t) return ESC .. "[1m" .. t .. ESC .. "[0m" end
local function color(code, t) return ESC .. "[" .. code .. "m" .. t .. ESC .. "[0m" end
local function row(label, value) return string.format("%s %s", color("1;34", string.format("%-12s", label)), value) end

-- Prints the screen, then waits until one of $KEYS is pressed and writes it to stderr.
-- Other keys are ignored, so stray vim habits (ZQ, ZZ, :q) don't leave the screen or reach yazi.
local SCREEN_SCRIPT = [[
printf '\033[H\033[2J%s\n\n%s\n%s' "$BODY" "$FOOTER" "$STATUS"
while :; do
	IFS= read -rsn1 k < /dev/tty || exit 0
	if [ -n "$k" ]; then
		case "$KEYS" in *"$k"*) printf '%s' "$k" >&2; exit 0 ;; esac
	fi
done
]]

-- Shows `lines` as plain terminal text with the yazi UI hidden. Hiding the UI also turns off
-- yazi's mouse capture, so the mouse belongs to tmux again: drag-select or double-click copies.
-- `keys` is a list of { key, label, value }: pressing a key copies its value (ya.clipboard:
-- OSC 52 + xclip) and keeps the screen open. Only `q` closes it.
local function show_screen(lines, keys)
	local hints, by_key, accepted = {}, {}, "q"
	for _, k in ipairs(keys) do
		if k.value and k.value ~= "?" then
			by_key[k.key] = k
			accepted = accepted .. k.key
			hints[#hints + 1] = color("1;33", k.key) .. " copy " .. k.label
		end
	end
	hints[#hints + 1] = color("1;33", "q") .. " close"
	local footer = table.concat(hints, "  ") .. "  " .. color("2", "(mouse selection also copies in tmux)")

	local permit = ui.hide()
	local status, failure = "", nil
	while true do
		local child, err = Command("bash")
			:arg({ "-c", SCREEN_SCRIPT })
			:env("BODY", table.concat(lines, "\n"))
			:env("FOOTER", footer)
			:env("STATUS", status)
			:env("KEYS", accepted)
			:stdin(Command.INHERIT)
			:stdout(Command.INHERIT)
			:stderr(Command.PIPED)
			:spawn()
		if not child then
			failure = "Failed to start bash: " .. tostring(err)
			break
		end
		local out = child:wait_with_output()
		local pick = by_key[out and out.stderr or ""]
		if not pick then
			break -- q, or bash ended without a key
		end
		ya.clipboard(pick.value)
		status = color("32", "Copied " .. pick.label .. ": " .. pick.value)
	end
	permit:drop()

	if failure then
		notify(failure, "error")
	end
end

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

	local lines = { bold("Properties: " .. basename(path)), "" }
	local values = { path = path, name = basename(path) }
	for _, r in ipairs(rows) do
		lines[#lines + 1] = row(r[1], r[2])
		values[r[1]] = r[2]
	end
	show_screen(lines, {
		{ key = "m", label = "MD5", value = values.MD5 },
		{ key = "s", label = "SHA256", value = values.SHA256 },
		{ key = "p", label = "path", value = values.path },
		{ key = "n", label = "name", value = values.name },
	})
end

----------------------------------------------------------------------------
-- Compare
----------------------------------------------------------------------------

local function mark_ref(st)
	if not st.hovered then
		return notify("Nothing hovered", "warn")
	end
	if st.ref == st.hovered then
		set_ref(nil)
		return notify("Compare reference cleared")
	end
	set_ref(st.hovered)
	notify("Compare reference: " .. tilde(st.hovered) .. "\nNow hover another file and press e c")
end

-- Size, mtime and checksums of a regular file (symlinks are followed).
local function file_info(path)
	local cha = fs.stat(Url(path), true)
	if not cha then
		return nil, "No longer exists: " .. path
	end
	if cha.is_dir then
		return nil, "Not a file: " .. path
	end
	local mtime = run("stat", { "-L", "-c", "%y", "--", path }) or "?"
	return {
		path = path,
		size = cha.len,
		mtime = (mtime:gsub("%.%d+", "")),
		md5 = first_field(run("md5sum", { "--", path })) or "?",
		sha = first_field(run("sha256sum", { "--", path })) or "?",
	}
end

local function compare(st)
	local a, b
	if #st.selected == 2 then
		a, b = st.selected[1], st.selected[2]
	elseif #st.selected > 0 then
		return notify("Select exactly 2 files to compare (" .. #st.selected .. " selected)", "warn")
	elseif not st.ref then
		return notify("No reference yet: press e r on the first file, then e c on the second.\nOr select exactly 2 files.", "warn")
	elseif not st.hovered or st.hovered == st.ref then
		return notify("Hover a different file than the reference: " .. tilde(st.ref), "warn")
	else
		a, b = st.ref, st.hovered
	end

	local fa, ea = file_info(a)
	local fb, eb = fa and file_info(b)
	if not fa or not fb then
		return notify(ea or eb, "error")
	end

	local verdict
	if fa.sha == "?" or fb.sha == "?" then
		verdict = color("1;33", "UNKNOWN") .. " (could not read one of the files)"
	elseif fa.size == fb.size and fa.sha == fb.sha then
		verdict = color("1;32", "IDENTICAL") .. " (same size, MD5 and SHA256)"
	elseif fa.size ~= fb.size then
		verdict = color("1;31", "DIFFERENT") .. string.format(" (sizes differ by %d bytes)", fb.size - fa.size)
	else
		verdict = color("1;31", "DIFFERENT") .. " (same size, different content)"
	end

	local lines = { bold("Compare"), "" }
	for i, f in ipairs { fa, fb } do
		lines[#lines + 1] = color("1;35", tostring(i)) .. " " .. row("Path", f.path)
		lines[#lines + 1] = "  " .. row("Size", string.format("%s (%d bytes)", human(f.size), f.size))
		lines[#lines + 1] = "  " .. row("Modified", f.mtime)
		lines[#lines + 1] = "  " .. row("MD5", f.md5)
		lines[#lines + 1] = "  " .. row("SHA256", f.sha)
		lines[#lines + 1] = ""
	end
	lines[#lines + 1] = row("Result", verdict)

	show_screen(lines, {
		{ key = "1", label = "MD5 of 1", value = fa.md5 },
		{ key = "2", label = "MD5 of 2", value = fb.md5 },
	})
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
	elseif action == "mark_ref" then
		mark_ref(st)
	elseif action == "compare" then
		compare(st)
	else
		notify("Unknown action: " .. action, "error")
	end
end

return M
