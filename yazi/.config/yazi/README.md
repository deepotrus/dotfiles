# Yazi config

Personal yazi config with two self-written plugins: **fzfmarks** (bookmarks) and **pins** (pin items to the top of a folder).

## Environment

- yazi is a **development build from `main`**, installed with cargo into `~/.cargo/bin`:
  `cargo install --force --git https://github.com/sxyazi/yazi.git yazi-build`
  (built 2026-09-29, commit `5d90049`). `~/.cargo/bin` comes before `/usr/bin` in PATH.
- The stable apt package (`yazi` 26.9.1, official yazi apt repo) is still installed as a fallback. It does **not** support `sort_by = "custom"`, so the pins plugin won't work on it.
- To go back to stable: `cargo uninstall yazi-build`, then `hash -r`.
- The yazi source for the installed build is at `~/.cargo/git/checkouts/yazi-*/5d90049/`. Check APIs there first, not in online docs.
- fzf 0.60 at `/usr/bin/fzf`. `$EDITOR` is not set.

## Files

| File | Purpose |
|---|---|
| `keymap.toml` | All custom bindings (`mgr.prepend_keymap`) |
| `yazi.toml` | `sort_by = "custom"`, `sort_fallback = "alphabetical"`. Required by pins |
| `init.lua` | `require("pins"):setup()` |
| `plugins/fzfmarks.yazi/main.lua` | Bookmarks plugin |
| `plugins/pins.yazi/main.lua` | Pins plugin |
| `package.toml` | Leftover from yamb/whoosh experiments. Not used; the listed packages aren't installed |

### Data files (not in this folder)

This folder is meant to be stowed from `~/.dotfiles`, so user data lives outside it, in `$XDG_DATA_HOME/yazi/` (default `~/.local/share/yazi/`):

| File | Purpose |
|---|---|
| `bookmarks.tsv` | Bookmark data: `name<TAB>absolute path`, one per line, file order = list order |
| `pins.txt` | Pin data: one absolute path per line |

Both plugins create the folder with `fs.create("dir_all", ...)` on first use, so a fresh machine needs no setup. Either path can be overridden with `require("fzfmarks"):setup{ file = "..." }` / `require("pins"):setup{ file = "..." }`.

## Keybindings

| Keys | Action |
|---|---|
| `'` or `b b` | Bookmarks: open the fzf picker |
| `b a` / `b A` | Bookmarks: add current directory / hovered item |
| `b p` | Pins: toggle pin on hovered item |
| `, c` | Back to custom sort (pins on top) after using another sort mode |
| `t d` | Close current tab (built-in `close`; quits on the last tab) |

## fzfmarks (bookmarks)

Written from scratch; the idea comes from zsh's fzf-marks. There are no key slots and no limit on entries.

- Hides the yazi UI (`ui.hide()`), runs `fzf` with `FZF_DEFAULT_COMMAND="cat bookmarks.tsv"`, and parses stdout.
- fzf options: `--delimiter=\t --with-nth=1`, so only names are shown and searched. The path is field `{-1}` and appears at the top of the preview.
- Inside fzf: `enter` cd (or `reveal` if the bookmark is a file), `ctrl-t` new tab (`--expect`), `ctrl-d` delete (`grep -vxF` + `reload`), `ctrl-e` edit the TSV (`$VISUAL`/`$EDITOR`/`vi`).
- Adding asks for a name with `ya.input` (passes both `pos` and the older `position`), and refuses duplicate paths.

## pins

Uses the custom-sort API from yazi PR #4363 (merged 2026-09-19). Facts checked against the source:

- Ranks are sent with `ya.emit("update_files", { op = fs.op("rank", { url = folder.cwd, ranks = { [file.url.key] = n } }) })`. Negative ranks sort first, `0` removes a rank.
- Rank keys must be `file.url.key` values (userdata; for local files this is the file name). Plain strings haven't been verified to work, so the plugin iterates `folder.files` to get the keys.
- Ranks are stored per folder (`Entries.ranks`) and survive reloads. Sending a rank op does **not** fire a `load` event, so there's no feedback loop.
- `sort_dir_first` is applied **before** ranks. Pinned folders go to the top of the folders, and pinned files to the top of the files (below all folders). Not yet done: pinning above everything like nemo, which would need `sort_dir_first = false` plus ranking every folder in the plugin.
- `sort_reverse` probably reverses ranks too (untested).

How the plugin works:

- `setup()` loads `pins.txt` (a missing file just means no pins) into `state.pins[dir][name]`, subscribes to `ps.sub("load", ...)`, and applies ranks to the matching folder (current, parent or preview of the active tab). Folders load in chunks, so ranks are re-sent on each load event.
- The 📌 marker comes from `Entity:children_add(fn, 4500)`, placed after the file name.
- Toggling rewrites `pins.txt` and sends rank `-1`, or `0` for an unpinned item.
- Known limitation: pins are stored by path, so renaming or moving a pinned item drops its pin.

## If something breaks

1. Check the yazi version: `yazi --version`. If the build date is before 2026-09-19, or it's the apt build, custom sort is missing.
2. Look at the log: run `YAZI_LOG=debug yazi`, then check `~/.local/state/yazi/yazi.log`. The `/dev/disk/by-label` errors there are unrelated noise.
3. After a yazi update, grep the new source for renamed APIs: `fs.op`, `"rank"`, `update_files`, `Entity:children_add`, `ps.sub`, `ui.hide`, `ya.emit`.
4. Headless smoke test used during development (checks order and the 📌 marker in the captured screen):
   ```sh
   YAZI_LOG=debug timeout 4 script -qfc "stty cols 120 rows 20; yazi /some/dir" /dev/null > screen.raw
   sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' screen.raw | tr -d '\r' | less
   ```
