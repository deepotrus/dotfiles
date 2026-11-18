#!/bin/bash
# Check the system requirements of themegen (Materia GTK theme + icon themes).
#
# Usage:
#   check-deps.sh        print one line per check, a summary line, exit 1 if
#                        something required is missing
#
# Requirements were taken from the scripts main.py actually runs:
#   materia-theme/change_color.sh  -> meson + ninja build, sass, rendersvg
#   icons_*/change_color.sh        -> bash, sed, find, bc (numix)
#   fetch-upstream.sh              -> git, tar, patch

set -uo pipefail

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
OK=0
MISSING=0
WARN=0

ok()      { printf '  ok       %-22s %s\n' "$1" "$2"; OK=$((OK + 1)); }
missing() { printf '  MISSING  %-22s %s\n' "$1" "$2"; MISSING=$((MISSING + 1)); }
warn()    { printf '  warn     %-22s %s\n' "$1" "$2"; WARN=$((WARN + 1)); }

need() { # command, hint if missing
    if command -v "$1" > /dev/null; then
        ok "$1" "$(command -v "$1")"
    else
        missing "$1" "$2"
    fi
}

echo "== basic tools"
need bash    "sudo apt install bash"
need sed     "sudo apt install sed"
need find    "sudo apt install findutils"
need mktemp  "sudo apt install coreutils"
need bc      "sudo apt install bc        (numix icons)"

echo "== download (fetch-upstream.sh)"
need git     "sudo apt install git"
need tar     "sudo apt install tar"
need patch   "sudo apt install patch"

echo "== python"
if command -v python3 > /dev/null && python3 -c 'import sys; sys.exit(sys.version_info < (3, 9))'; then
    ok python3 "$(python3 --version 2>&1) (main.py needs >= 3.9, standard library only)"
else
    missing python3 "python3 >= 3.9 (sudo apt install python3)"
fi

echo "== materia GTK theme build"
need meson   "sudo apt install meson"
need ninja   "sudo apt install ninja-build"

# meson.build wants dart-sass >= 1.23; otherwise it runs 'npm install' inside
# the temporary build folder on every theme build (needs npm and network)
SASS_VERSION=""
command -v sass > /dev/null && SASS_VERSION="$(sass --version 2>/dev/null | head -1)"
if [ -n "$SASS_VERSION" ] && ! echo "$SASS_VERSION" | grep -q 'Ruby Sass' \
   && printf '%s\n1.23.0\n' "$SASS_VERSION" | sort -V -C -r 2>/dev/null; then
    ok sass "dart-sass $SASS_VERSION"
elif command -v npm > /dev/null; then
    warn sass "${SASS_VERSION:-not found}: not dart-sass >= 1.23, each build downloads it with npm (needs network); install once: sudo npm install -g sass"
else
    missing sass "dart-sass >= 1.23 or npm: sudo apt install npm  (or: sudo npm install -g sass)"
fi

# GTK2/3 PNG assets must be rendered with rendersvg (resvg). Without it the
# Materia scripts fall back to Inkscape, and Inkscape 1.x exports the whole
# page instead of each asset (broken 812x944 PNGs).
if command -v rendersvg > /dev/null; then
    ok rendersvg "$(readlink -f "$(command -v rendersvg)")"
else
    missing rendersvg "required (Inkscape is not a working fallback): cargo install resvg && sudo ln -s ~/.cargo/bin/resvg /usr/bin/rendersvg"
fi

if command -v optipng > /dev/null; then
    ok optipng "$(command -v optipng)"
else
    warn optipng "optional, smaller PNG assets: sudo apt install optipng"
fi

echo "== input and sources"
COLORS="$HOME/.cache/wal/colors-oomox"
if [ -f "$COLORS" ]; then
    ok colors-oomox "$COLORS"
else
    missing colors-oomox "$COLORS not found: run wal first (themesel does)"
fi

for d in materia-theme icons_numix icons_papirus icons_suruplus; do
    if [ -f "$SCRIPT_DIR/$d/change_color.sh" ]; then
        ok "$d" "$SCRIPT_DIR/$d"
    else
        missing "$d" "run $SCRIPT_DIR/fetch-upstream.sh"
    fi
done

if [ -f "$SCRIPT_DIR/materia-theme/src/gtk-2.0/assets.txt" ] \
   && grep -qx 'handle-horz-hover' "$SCRIPT_DIR/materia-theme/src/gtk-2.0/assets.txt"; then
    missing materia-patch "patches/materia-theme-assets.patch not applied: patch -p1 -d materia-theme < patches/materia-theme-assets.patch"
elif [ -d "$SCRIPT_DIR/materia-theme" ]; then
    ok materia-patch "patches/materia-theme-assets.patch applied"
fi

echo "check-deps: $OK ok, $MISSING missing, $WARN warnings"
[ "$MISSING" -eq 0 ]
