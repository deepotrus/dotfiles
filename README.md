# Debian 12 Bookworm Personal Dotfiles
These are my personal dotfiles for the configuration and personalization of my desktop linux. I have chosen Debian 12 as a challenge for compiling from source all programs and dependencies, and having it stable.
## How to rice with pywal
I use pywal16, from github.com/eylles/pywal16 which i install on bookworm with python into a python environment:
```shell
$ git clone https://github.com/eylles/pywal16
$ cd pywal16
$ pip3 install --user .
$ export PATH="${PATH}:${HOME}/.local/bin"
```
Here pip will install pywal under .local/bin and The last export is for running the command wal outside of .local/bin
```bash
$ wal -i /path/to/wallpaper
```
## How to create custom theme for thunar and libreoffice with themix
I currently use oomox for creating colorized versions of materia gtk theme (the best imho). Of course oomox on debian 12 is out of date and to make it work there are many caveats.
```bash
$ sudo apt install lxappearance
$ sudo apt install materia-gtk-theme
```
With oomox we will create a general theme and an icon theme. Don't download the release as tarballs, just clone the repo and build it.
```bash
$ git clone --recursive https://github.com/themix-project/themix-gui.git
```
Now if you cd into it and run ./gui.sh there are many uninstalled dependencies.
```bash
$ sudo apt install python3-gi
$ sudo apt install python3-pillow
$ sudo apt install python3-pystache
$ sudo apt install python3-yaml
```
Once the gui works, for building themes there are some libraries needed, which for debian 12 are:
```bash
$ sudo apt install gettext
$ sudo apt install sassc
$ sudo apt install librsvg2-2
$ sudo apt install librsvg2-bin (for the binary rsvg-convert)
$ sudo apt install libglib2.0-0
$ sudo apt install libglib2.0-dev-bin (for missing binary glib-compile-resources)
$ sudo apt install libgdk-pixbuf2.0-0
$ sudo apt install meson
$ sudo apt install npm
$ sudo apt install optipng
```
For debian 12 bookworm if you want materia theme with oomox then there is a known problem of inkscape getting stuck and fills the ram freezing your system. For this you have to force using resvg instead of inkscape. If you notive resvg does not exist for debian 12 bookworm, so you build it with rust to get the binaries. Download release from this https://github.com/linebender/resvg , cd into it and:
```bash
$ cargo build --release
$ cd target/release
$ sudo cp resvg /usr/bin
```
Now you also need to edit source of materia inside oomox plugins, the folder is oomox/plugins/theme_materia/materia-theme
By using resvg you have to make sure that the binaries name are NOT rendersvg, as shown in render_assets.sh, so here is a command which substitutes that for you (you can also create symlink)
```bash
$ find -name '*.sh' | xargs sed -i 's/rendersvg/resvg/g; s/--export-id/--export-area-drawing --export-id/g'
sed '/handle-/d' -i src/gtk-2.0/assets.txt
```
Finally you have to comment a line inside change_colors.sh, the one with set -ueo pipefail.
### Last touch for thunar CSS Hacks
I created some css hack in gtk-3.0 dotfile for thunar rubberband and selection icon bug of invisible icon when selected.
## Now combine everything
With lxappearance GUI it is easy to set new custom themes with pywal colors, exported with oomox in the folders ~/.themes (general theme) and ~/.icons (for file manager icons). If you wish to use a custom cursor theme, you will have to put the files inside ~/.icons, and lxappearance will recognize it.
