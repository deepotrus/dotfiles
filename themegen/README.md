# themegen

Generates a pywal-coloured Materia GTK theme, and optionally an icon theme, from
`~/.cache/wal/colors-oomox`, using the themix-gui (oomox) build scripts without the GUI.
GTK assets are rendered with resvg (`rendersvg`), not Inkscape.

```bash
$ themegen --id wy3j67 --icons suru
$ themegen --id wy3j67 --icons numix --numix-style 3
$ themegen --id wy3j67 --icons papirus --light
```
`themegen` is the wrapper in `~/.dotfiles/bin` (on the PATH, see the main README); it runs
`main.py` with `~/.base/bin/python` when that exists, otherwise `python3`.
Output:
- GTK theme  → `~/.themes/pywal-materia-themes/dark|light/pywal-materia-<id>/`
- icon theme → `~/.icons/pywal-icons/icons-<id>/`

`main.py` only uses the Python standard library (>= 3.9); any `python3` works.

## Setup on a new machine

```bash
$ ./fetch-upstream.sh   # downloads the upstream sources (~500 MB), applies patches/
$ ./check-deps.sh       # checks the system requirements, ends with a summary line
```

The upstream sources are not tracked (see `.gitignore`):

| Folder | Source |
|---|---|
| `materia-theme/` | nana-4/materia-theme |
| `icons_numix/` | themix-gui plugin + numix-icon-theme, numix-folders |
| `icons_papirus/` | themix-gui plugin + papirus-icon-theme |
| `icons_suruplus/` | themix-gui plugin + suru-plus |

Versions are pinned by the themix-gui commit in `fetch-upstream.sh` (the submodule commits
of that themix-gui revision). To update, change `THEMIX_COMMIT`, remove the four folders and
run `fetch-upstream.sh` again.

## Local fixes

- `patches/materia-theme-assets.patch`: `src/gtk-2.0/assets.txt` lists four
  `handle-*-hover/active` assets that do not exist in `assets.svg`; rendering them fails
  and stops the build, so they are removed.
- `main.py` passes `--inkscape False` to Materia's `change_color.sh`, which otherwise forces
  Inkscape. Inkscape 1.x exports the whole page instead of one asset (812x944 PNGs instead
  of 20x20), so resvg is used.

## Requirements (Debian 13)

`check-deps.sh` reports all of these. The non-obvious ones:

- resvg as `rendersvg`, **required**: Inkscape is not a working fallback, and `main.py` stops
  before building if `rendersvg` is missing. On Debian 13 it is installed with cargo:
  ```bash
  $ cargo install resvg
  $ sudo ln -s ~/.cargo/bin/resvg /usr/bin/rendersvg
  ```
- meson, ninja: `sudo apt install meson ninja-build`
- dart-sass >= 1.23. Debian's `sass` package is the old Ruby Sass, which Materia rejects; it
  then runs `npm install` on every build (needs `npm` and network). Installing dart-sass once
  avoids that: `sudo npm install -g sass`
- optional: `optipng` (smaller PNG assets)

The python packages that oomox/themix needed (python3-gi, pillow, pystache, yaml) are not
needed by this CLI.
