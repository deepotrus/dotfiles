#!/bin/bash
# Download the upstream theme sources used by main.py, at pinned versions.
#
# The sources are the themix-gui (oomox) plugins plus their git submodules:
#   materia-theme/   <- nana-4/materia-theme                 (GTK theme)
#   icons_numix/     <- themix plugin + numix-icon-theme, numix-folders
#   icons_papirus/   <- themix plugin + papirus-icon-theme
#   icons_suruplus/  <- themix plugin + suru-plus
# They are large (~500 MB) and ignored by git (see .gitignore).
# Local fixes in patches/<folder>-*.patch are applied after the download.
#
# Usage:
#   fetch-upstream.sh [TARGET_DIR]     default: the folder of this script
#
# Existing source folders in TARGET_DIR are not overwritten; remove them first
# to download again.

set -euo pipefail

# themix-gui commit the submodule versions are taken from
THEMIX_REPO="https://github.com/themix-project/themix-gui"
THEMIX_COMMIT="e733949a267abb3ac4629a31366ecc9afc726d8c"

SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"
TARGET="$(readlink -f "${1:-$SCRIPT_DIR}")"
CACHE="$TARGET/.upstream"          # git checkouts, ignored by git

# shallow checkout of one commit: repo url, commit, destination
fetch_commit() {
    local url=$1 commit=$2 dest=$3
    if [ -d "$dest/.git" ] && [ "$(git -C "$dest" rev-parse HEAD 2>/dev/null)" = "$commit" ]; then
        echo "    up to date: $dest"
        return
    fi
    rm -rf "$dest"
    mkdir -p "$dest"
    git -C "$dest" init -q
    git -C "$dest" remote add origin "$url"
    git -C "$dest" fetch -q --depth 1 origin "$commit"
    git -C "$dest" -c advice.detachedHead=false checkout -q FETCH_HEAD
}

# commit of a submodule as pinned in the themix checkout
pinned() {
    git -C "$CACHE/themix-gui" ls-tree HEAD "$1" | awk '{print $3}'
}

# copy a checkout without its .git folder
copy_tree() {
    local src=$1 dest=$2
    mkdir -p "$dest"
    (cd "$src" && tar --exclude=.git -cf - .) | (cd "$dest" && tar -xf -)
}

for d in materia-theme icons_numix icons_papirus icons_suruplus; do
    if [ -e "$TARGET/$d" ]; then
        echo "fetch-upstream: $TARGET/$d already exists, remove it first to download again" >&2
        exit 1
    fi
done

echo "==> themix-gui $THEMIX_COMMIT"
fetch_commit "$THEMIX_REPO" "$THEMIX_COMMIT" "$CACHE/themix-gui"
P="$CACHE/themix-gui/plugins"

echo "==> materia-theme"
fetch_commit https://github.com/nana-4/materia-theme.git \
    "$(pinned plugins/theme_materia/materia-theme)" "$CACHE/materia-theme"
copy_tree "$CACHE/materia-theme" "$TARGET/materia-theme"
for p in "$SCRIPT_DIR"/patches/materia-theme-*.patch; do
    echo "    patch: $(basename "$p")"
    patch -s -p1 -d "$TARGET/materia-theme" < "$p"
done

echo "==> icons_numix"
fetch_commit https://github.com/numixproject/numix-icon-theme.git \
    "$(pinned plugins/icons_numix/numix-icon-theme)" "$CACHE/numix-icon-theme"
fetch_commit https://github.com/numixproject/numix-folders.git \
    "$(pinned plugins/icons_numix/numix-folders)" "$CACHE/numix-folders"
copy_tree "$P/icons_numix" "$TARGET/icons_numix"
copy_tree "$CACHE/numix-icon-theme" "$TARGET/icons_numix/numix-icon-theme"
copy_tree "$CACHE/numix-folders" "$TARGET/icons_numix/numix-folders"

echo "==> icons_papirus"
fetch_commit https://github.com/PapirusDevelopmentTeam/papirus-icon-theme.git \
    "$(pinned plugins/icons_papirus/papirus-icon-theme)" "$CACHE/papirus-icon-theme"
copy_tree "$P/icons_papirus" "$TARGET/icons_papirus"
copy_tree "$CACHE/papirus-icon-theme" "$TARGET/icons_papirus/papirus-icon-theme"

echo "==> icons_suruplus"
fetch_commit https://github.com/gusbemacbe/suru-plus.git \
    "$(pinned plugins/icons_suruplus/suru-plus)" "$CACHE/suru-plus"
copy_tree "$P/icons_suruplus" "$TARGET/icons_suruplus"
copy_tree "$CACHE/suru-plus" "$TARGET/icons_suruplus/suru-plus"

echo "fetch-upstream: done ($(du -sh "$TARGET/materia-theme" "$TARGET"/icons_* | awk '{s=s" "$1} END{print s}' ))"
