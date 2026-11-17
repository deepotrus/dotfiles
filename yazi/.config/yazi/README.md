# Yazi config

Personal yazi config with three self-written plugins: **fzfmarks** (bookmarks), **pins** (pin items to the top of a folder) and **fileops** (compress / extract / properties / compare menu).

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
| `plugins/fileops.yazi/main.lua` | File operations menu |
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
| `e` | File operations menu, then `t` .tar.gz, `T` .tar, `z` .zip, `x` extract, `p` properties, `r` mark compare reference, `c` compare |

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

## fileops

`e` opens a which-key style menu (`ya.which`). Each entry can also be bound directly, e.g. `run = "plugin fileops zip"` (actions: `tar_gz`, `tar`, `zip`, `extract`, `props`, `mark_ref`, `compare`).

- **Compress** (`t`/`T`/`z`) works on the selection, or the hovered item if nothing is selected. Asks for the archive name (default: item name, or folder name for several items) and creates it in the current folder. Members are stored relative to their parent, so all selected items must be in one folder. Asks before overwriting.
- **Extract** (`x`) supports `.tar[.gz|.xz|.bz2|.zst]`, `.tgz/.txz/.tbz2` (via `tar -xf`, compression auto-detected) and `.zip/.jar` (via `unzip`). It extracts into a hidden temp folder next to the archive; a single top-level entry is moved up as is (no `foo/foo/` nesting), several entries go into a folder named after the archive. Never overwrites: existing names get a `_1`, `_2`, ... suffix. A failed extraction that produced nothing leaves nothing behind.
- **Properties** (`p`) on the hovered item: path, type (`stat` + `file -b`), size (bytes and KiB/MiB; `du -sb` and recursive item count for folders), permissions, owner, mtime, link target, and MD5 + SHA256 for files. Shown as plain terminal text with the yazi UI hidden (`ui.hide()`, which also turns off yazi's mouse capture), so the text is selectable: in tmux, drag or double-click copies it (tmux `copy-pipe-and-cancel` + `set-clipboard on` → OSC 52 → kitty). Keys on that screen: `m` copy MD5, `s` copy SHA256, `p` copy full path, `n` copy name (the screen stays open and shows what was copied); only `q` closes it. All other keys are ignored on purpose, so vim habits like `ZQ` don't fall through to yazi and quit it. Copying uses `ya.clipboard`, which writes OSC 52 and also runs `xclip`. A small `bash` script prints the text and returns the pressed key on stderr; the plugin re-shows the screen after each copy while keeping the UI hidden.
- **Compare** (`r` / `c`): `e r` marks the hovered file as reference (stored in the plugin state, so it survives folder and tab changes; `e r` on the same file clears it). `e c` compares the reference with the hovered file, or the two selected files if exactly 2 are selected (a selection can span folders). Shows both full paths, sizes, mtimes, MD5 and SHA256, and a verdict: IDENTICAL (same size and SHA256) or DIFFERENT (with the size difference or "same size, different content"). Same screen as Properties: `1`/`2` copy each MD5, `q` closes, mouse selection copies. Folders are refused.
- `cx.active.selected` yields file objects in this build, so the plugin uses `f.url`.
- Tested headless by driving yazi in a pty and rendering the screen with `pyte`. The pty must answer yazi's terminal queries (DA1 `ESC[0c`, OSC 11, `ESC[?u`), otherwise `ui.hide()` never returns and fzf/bash screens don't appear.

## If something breaks

1. Check the yazi version: `yazi --version`. If the build date is before 2026-09-19, or it's the apt build, custom sort is missing.
2. Look at the log: run `YAZI_LOG=debug yazi`, then check `~/.local/state/yazi/yazi.log`. The `/dev/disk/by-label` errors there are unrelated noise.
3. After a yazi update, grep the new source for renamed APIs: `fs.op`, `"rank"`, `update_files`, `Entity:children_add`, `ps.sub`, `ui.hide`, `ya.emit`.
4. Headless smoke test used during development (checks order and the 📌 marker in the captured screen):
   ```sh
   YAZI_LOG=debug timeout 4 script -qfc "stty cols 120 rows 20; yazi /some/dir" /dev/null > screen.raw
   sed 's/\x1b\[[0-9;?]*[a-zA-Z]//g' screen.raw | tr -d '\r' | less
   ```
