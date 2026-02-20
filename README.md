# Debian 13 Trixie XFCE4 Dotfiles
These are my personal dotfiles for the configuration and personalization of my desktop linux. I have chosen Debian 12 as a challenge for compiling from source all programs and dependencies, and having it stable.
## Remote dots
There are remote dotsfile for remote machines which have different configuration from the local.
```shell
$ scp -r .remotedots user@remotehost:/home/user/
$ ssh user@remotehost
$ cd ~/.remotedots
$ stow vim
$ stow tmux
```
For example, vim config for remote includes OSC 52 clipboard for vim yanking in ssh sessions. This allows for setups with tmux, ssh and edit remote files with vim, yank some text and now it is available on local machine clipboard.
## How to rice with pywal
I use pywal16, from github.com/eylles/pywal16 which i install on trixie with python into without using python environment, but using pipx instead:
```shell
$ sudo apt install pipx
$ pipx install git+https://github.com/dylanaraps/pywal
$ export PATH="${PATH}:${HOME}/.local/bin"
$ wal -i /path/to/wallpaper

## Custom themix theme
I currently use oomox for creating colorized versions of materia gtk theme (the best imho).
```bash
$ sudo apt install materia-gtk-theme
```
With themix-gui one can create a general theme and an icon theme.
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
Once the gui works, for building themes there are some libraries needed, which for debian 13 are:
```bash
$ sudo apt install gettext
$ sudo apt install sassc
$ sudo apt install ... a lot of other stuff
```
Once all dependencies are installed, cd into themix-gui and run the gui.sh script which will open a gui where you can customize you themes based on pywal colors!
### Note on Xfce4 borders and gtk themes
Few people know that in xfce4 you can set independently the borders of the windows, and the gtk theme for the "internal" of the window.
It is possible to make xfwm inherit the colors from gtk theme, which is created with themix-gui. Changing gtk theme would automatically change the border color of your open applications runtime. Here, stow is used for creating symbolic links automatically.
```bash
$ cd dotfiles
$ stow xfwm-borders
```
Then, in xfce4 go to Settings > Window Manager > Style, and select xfwm-borders. The second xfwm-borders theme includes rounded borders which was adjusted by me for picom compositor with rounded corner option. This allows to have rounded and colored borders on Xfce4!

Now combine everything! With lxappearance GUI it is easy to set new custom themes with pywal colors, exported with oomox in the folders ~/.themes (general theme) and ~/.icons (for file manager icons). If you wish to use a custom cursor theme, you will have to put the files inside ~/.icons, and lxappearance will recognize it.

### Compositor and Activity Switcher
Use as picom as compositor for animations and skippy-xd for alt-tab behavior.
```bash
$ sudo apt install picom
$ cd dotfiles
$ stow picom
```
Then get skippy from here:
```bash
$ git clone https://github.com/felixfung/skippy-xd.git
```
For Debian 13 the installation instructions are provided here. For compiling skippy-xd there are some x dev packages required and some image libraries:
```bash
$ sudo apt install libxcomposite-dev libxdamage-dev libxfixes-dev libxinerama-dev
$ sudo apt install libjpeg-dev libgif-dev
```
Then cd into the skippy-xd repo and
```bash
$ make
$ make install
$ skippy-xd --start-daemon
```
There are more infos on the official page on how to use skippy-xd!

### Pywalfox on Debian 13
So, on debian it is a little bit harder, to make it easier you install pywalfox via python pip. But, the stable release has relative path which creates issue for Firefox to find the executable during runtime. So instead of running pip install pywalfox you do:
```bash
$ pip3 install --index-url https://test.pypi.org/simple/ pywalfox==2.8.0rc1
$ pywalfox install
```
Then download the add on from firefox and fetch colors.
### Walogram, aka Pywal for Telegram
Walogram is the new version of wal-telegram, and is not on github but on codeberg:
```bash
$ git clone https://codeberg.org/thirtysix/walogram.git
$ cd walogram
$ make install (as root if needed)
($ make uninstall to remove)
```
After you run wal and update colorscheme with pywal, run walogram:
```bash
$ walogram
```
Open telegram and go to Settings > Chat Settings, click on choose from file, navigate to ~/.cache/walogram/wal.tdesktop-theme. Click on keep changes.
Now whenever you change your pywal theme, also the telegram colors will change accordingly.

### Firefox 
Let xfce4 handle firefox decorations.
In about:config look for browser.tabs.inTitlebar and set to 0
### Stowing XFCE4
Stowing the dotfiles into ~/.config/xfce4 is not enough for the update to take effect. XFCE4 reads its config from xfconf (an in-memory daemon), not directly from XML files on disk. The xml files ~/.config/xfce4 are used only to initialize xfconf when no in-memory config exists. So no even a log out log in will update the new stowed xfce4 config. The simplest solution is to just reboot the system after stowing:
```bash
$ stow xfce4
$ sudo reboot
```

### Stowing tmux
I use tpm for tmux plugins. It is necessary to clone the tpm plugin from github in the correct dir:
```bash
$ cd dotfiles
$ stow tmux
$ git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
$ tmux source ~/.tmux.conf
```
Then open tmux and insert command prefix + I to install plugins!
