#!/usr/bin/env python3
"""
Standalone CLI to generate a Materia GTK theme and optional icon theme
from a pywal colors-oomox file.

Usage examples:
  python3 main.py --id rdkojj
  python3 main.py --id rdkojj --icons numix --numix-style 3
  python3 main.py --id rdkojj --icons papirus
  python3 main.py --id rdkojj --icons suru

Output:
  GTK theme  → <themes-dir>/pywal-materia-<id>/
  Icon theme → <icons-dir>/icons-<id>/
"""

import argparse
import os
import shutil
import subprocess
import sys
import tempfile

SCRIPT_DIR = os.path.dirname(os.path.realpath(__file__))

CHANGE_COLOR_SH = os.path.join(SCRIPT_DIR, "materia-theme", "change_color.sh")
NUMIX_SH        = os.path.join(SCRIPT_DIR, "icons_numix",   "change_color.sh")
PAPIRUS_SH      = os.path.join(SCRIPT_DIR, "icons_papirus", "change_color.sh")
SURU_SH         = os.path.join(SCRIPT_DIR, "icons_suruplus", "change_color.sh")

DEFAULT_INPUT       = "~/.cache/wal/colors-oomox"
DEFAULT_THEMES_BASE = os.path.expanduser("~/.themes/pywal-materia-themes")
DEFAULT_ICONS_DIR   = os.path.expanduser("~/.icons/pywal-icons")


def parse_colors(path: str) -> dict[str, str]:
    colors: dict[str, str] = {}
    with open(path) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue
            key, _, value = line.partition("=")
            colors[key.strip()] = value.strip()
    return colors


def write_colorscheme(colors: dict[str, str], path: str) -> None:
    with open(path, "w") as f:
        for key, value in colors.items():
            f.write(f"{key}={value}\n")


def run(cmd: list[str]) -> None:
    result = subprocess.run(cmd)
    if result.returncode != 0:
        sys.exit(result.returncode)


def with_temp_colorscheme(colors: dict[str, str], fn):
    tmp_fd, tmp_path = tempfile.mkstemp(suffix=".colors")
    try:
        os.close(tmp_fd)
        write_colorscheme(colors, tmp_path)
        fn(tmp_path)
    finally:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass


def export_gtk_theme(colors: dict[str, str], theme_name: str, themes_dir: str, hidpi: bool) -> None:
    print(f"==> Generating GTK theme: {theme_name}")

    def do_export(tmp_path: str) -> None:
        run([
            "bash", CHANGE_COLOR_SH,
            "--hidpi", "True" if hidpi else "False",
            # change_color.sh forces Inkscape by default, but Inkscape 1.x
            # exports the whole page instead of one asset (812x944 PNGs);
            # rendersvg (resvg) renders the GTK2/3 assets correctly
            "--inkscape", "False",
            "--target", themes_dir,
            "--output", theme_name,
            tmp_path,
        ])

    with_temp_colorscheme(colors, do_export)


def export_icon_theme(colors: dict[str, str], icons_name: str, icons_dir: str, icon_set: str, numix_style: int) -> None:
    print(f"==> Generating icon theme: {icons_name} ({icon_set})")

    icon_colors = dict(colors)
    output_path = os.path.join(icons_dir, icons_name)

    if icon_set == "numix":
        icon_colors["ICONS_NUMIX_STYLE"] = str(numix_style)
        script = NUMIX_SH
    elif icon_set == "papirus":
        script = PAPIRUS_SH
    elif icon_set == "suru":
        icon_colors["SURUPLUS_GRADIENT_ENABLED"] = "True"
        script = SURU_SH
    else:
        print(f"error: unknown icon set: {icon_set}", file=sys.stderr)
        sys.exit(1)

    def do_export(tmp_path: str) -> None:
        run([
            "bash", script,
            "--output", icons_name,
            "--destdir", output_path,
            tmp_path,
        ])

    with_temp_colorscheme(icon_colors, do_export)


def main() -> None:
    ap = argparse.ArgumentParser(
        description="Generate a Materia GTK theme and optional icon theme from pywal colors.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    ap.add_argument(
        "--id", required=True, metavar="ID",
        help="Theme ID (e.g. rdkojj). Sets output names: pywal-materia-ID and icons-ID",
    )
    ap.add_argument(
        "--input", default=DEFAULT_INPUT, metavar="PATH",
        help=f"Path to colors-oomox file (default: {DEFAULT_INPUT})",
    )
    ap.add_argument(
        "--light", action="store_true",
        help="Use light theme output directory (default: dark)",
    )
    ap.add_argument(
        "--themes-dir", default=None, metavar="DIR",
        help=f"Override GTK theme output directory (default: {DEFAULT_THEMES_BASE}/dark|light)",
    )
    ap.add_argument(
        "--icons-dir", default=DEFAULT_ICONS_DIR, metavar="DIR",
        help=f"Output directory for icon theme (default: {DEFAULT_ICONS_DIR})",
    )
    ap.add_argument(
        "--icons", choices=["numix", "papirus", "suru"], metavar="{numix,papirus,suru}",
        help="Icon theme to generate alongside the GTK theme",
    )
    ap.add_argument(
        "--numix-style", type=int, choices=range(6), default=0, metavar="N",
        help="Numix folder style 0–5 (default: 0, only applies when --icons numix)",
    )
    ap.add_argument(
        "--hidpi", action="store_true",
        help="Enable HiDPI mode for GTK2 assets",
    )
    args = ap.parse_args()

    input_path = os.path.expanduser(args.input)
    if not os.path.isfile(input_path):
        print(f"error: colors file not found: {input_path}", file=sys.stderr)
        sys.exit(1)

    for script in [CHANGE_COLOR_SH] + ([
        {"numix": NUMIX_SH, "papirus": PAPIRUS_SH, "suru": SURU_SH}[args.icons]
    ] if args.icons else []):
        if not os.path.isfile(script):
            print(f"error: script not found: {script}", file=sys.stderr)
            sys.exit(1)

    # GTK assets must be rendered with rendersvg (resvg): without it Materia's
    # scripts silently fall back to Inkscape, which produces broken assets
    if shutil.which("rendersvg") is None:
        print("error: rendersvg not found (resvg is required, Inkscape is not a working fallback):\n"
              "  cargo install resvg && sudo ln -s ~/.cargo/bin/resvg /usr/bin/rendersvg",
              file=sys.stderr)
        sys.exit(1)

    theme_id   = getattr(args, "id")
    theme_name = f"pywal-materia-{theme_id}"
    icons_name = f"icons-{theme_id}"

    variant = "light" if args.light else "dark"
    themes_dir = args.themes_dir or os.path.join(DEFAULT_THEMES_BASE, variant)

    colors = parse_colors(input_path)

    # Fixed materia overrides (matches the user's GUI workflow):
    # Surface (BTN_BG) always equals View (TXT_BG)
    colors["BTN_BG"] = colors.get("TXT_BG", colors.get("BG", "000000"))
    # Roundness always set to 4
    colors["ROUNDNESS"] = "4"

    export_gtk_theme(colors, theme_name, themes_dir, args.hidpi)

    if args.icons:
        export_icon_theme(colors, icons_name, args.icons_dir, args.icons, args.numix_style)


if __name__ == "__main__":
    main()
