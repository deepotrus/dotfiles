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
$ sudo apt install meson ninja-build
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
$ sudo apt install libxft-dev libx11-dev
$ sudo apt install libxcomposite-dev libxdamage-dev libxfixes-dev libxinerama-dev
$ sudo apt install libjpeg-dev libgif-dev
```
Then cd into the skippy-xd repo and
```bash
$ make
$ sudo make install
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

### Firefox with Picom
Let xfce4 handle firefox decorations to avoid having big blurred borders artifacts when activating picom as compositor.
For this just go in firefox to about:config look for browser.tabs.inTitlebar and set to 0
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

## Fonts
I personally use fonts downloaded from https://www.nerdfonts.com/font-downloads. In particular JetBrainsMono Nerd Font and Symbols Nerd Font. Download them, extract and put them inside ~/.local/share/fonts.
```bash
$ fs-cache -vr
```
Now you have symbols with kitty terminal symbols Ctrl+Shift+U, and nice font on Rofi launcher. These fonts can be used e.g. on Polybar. For kitty terminal it is needed to map the symbols as shown in the kitty.conf file.

## Cursor theme: Graphite
My favorite cursor theme is Graphite from https://github.com/vinceliuice/Graphite-cursors.
```bash
$ git clone https://github.com/vinceliuice/Graphite-cursors.git
$ cd Graphite-cursors
$ ./build.sh
```
Then move the dist folders under ~/.icons, and use Settings > Mouse and Touchpad in XFCE4 for setting the mouse theme.

## Login Manager: LightDM
Since XFCE4 uses by default LightDM, why not use it. To make it easier to change settings and wallpaper, install settings:
```bash
$ sudo apt install lightdm-gtk-greeter-settings
```
It appears in the XFCE4 Settings, under the System section.
# Sound Debug
## Hardware setup
I reccommend using separately a USB microphone for input, and a headphones set as input which connects via bluetooth 5.1 on a supported chip.
## My software choices
I personally use pavucontrol for gui on xfce4. Then i use pulseaudio as sound service. You can find you current sound service with:
```bash
$ pactl info | grep "Server Name"
```
The status of pulseaudio is checked with:
```bash
$ systemctl --user status pipewire pulseaudio
```
Then you must make sure you have these services installed and running:
```bash
$ systemctl --user status pipewire-pulse wireplumber
```
If they are not active, i reccommend installing the packages:
```bash
$ sudo apt install bluetooth blueman
$ sudo apt install libspa-0.2-bluetooth pipewire-audio wireplumber
$ sudo apt install pulseaudio-module-bluetooth
```
Make sure to restart Discord after any update to refresh the thing.
# Gaming on Debian 13 Trixie
Follow https://wiki.debian.org/Steam for installing Steam on a fresh Debian install.

## Nvidia drivers
This setup is about Debian + XFCE + Nvidia. Using the DEbian guide https://wiki.debian.org/NvidiaGraphicsDrivers is pretty straightforward and reccommended.
Here we handle the situation where we need at least 575 driver version for most recent games like Doom The Dark Ages. In my case i installed the .sh script from Nvidia official page by navigating their repos. Once installed run:
```bash
  $ sudo chmod +x NVIDIA-Linux-x86_64-575.64.05.sh
  $ sudo ./NVIDIA-Linux-x86_64-575.64.05.sh
```
In options i used all yes and handle automatically.
To my knowledge, the 575 nvidia driver version is the most stable for XFCE4 4.20 and Debian 13. I tried the version 580 and xfce4 struggles creating glitches and flickering with the compositor.

## Games do not start from external hardisk
For steam games choose external hard disk. Why? Because you are a linux user, and you distro hop a lot.
We want the linux to run on smallest SSD, and the games stored on big SSD simply because if we have to reinstall linux we don't have to reinstall all the games.
```bash
$ lsblk -f
```
shows you the devices and UUID (unique identifier of your hardisks in the pc).

Example we target /dev/sdc1. Assume there is a lot of stuff you don't care. You don't have to delete them, or format the disk. Just make its filesystem ext4 (all files will be lost), which is the chosen one for gaming on Linux.
$ sudo mkfs.ext4 -L "SteamLibrary" /dev/sdc1

We assume the user is called $USER=popo
You need to build the mount moint so that it is also seen by the filemanager (like nemo, thunar, files, ...).
The path then must be /media/popo
```bash
$ sudo mkdir -p /media/popo/SteamLibrary
```
The user must be owner of the steam disk! Otherwise steam won't recognize it as a valid storage location for installing games!
```bash
$ sudo chown -R popo:popo /media/popo/SteamLibrary
```
To make the setup persistent on boot you need to add a line in /etc/fstab
UUID=6ab40807-b0d3-41b3-82de-e1966e8e95f3 /media/popo/SteamLibrary ext4 defaults,nofail  0  2
Where:
  The uuid is taken from lsblk -f
  NOTE uid=1000 and gid=1000 is NOT USED for ext4 partitions

To test the /etc/fstab before rebooting, launch
```bash
$ sudo mount -a
```
This helps not going in kernel panick when playing with /etc/fstab.
NOTE:
Do not use TABS in /etc/fstab, otherwise your systemd will not load, and you will have to recover

## Controllers GAMESIR Nova Lite 2
I chose this controllers for my Linux setup because they are natively compatible, plug and play.
Here I discuss a functioning setup with 2 of these controllers, which gave me a bit of headache when playing with one my friend together and steam not letting me.
If you are using 2 same controllers, their MAC address is unique, thus Steam will only see ONE of these controllers. This happens because the playstation kernel driver has an explicit MAC-based deduplication check in its source code. Since GameSir hardcodes the same fake MAC on every Nova 2 unit, the driver refuses to register a second device with that address, it assumes it must be the same physical controller reconnecting, not a second one.
### Solution
Switching both controllers from DS4 mode to Xinput (the one of xbox) solves the problem because the playstation driver is bypassed. To force Xinput mode:
- Unplug both controllers
- Hold Home + X while plugging each one back in (this forces XInput mode)
- Relaunch Steam if needed
At the end check Steam > Settings > Controller, and see if 2 gamepads xpox are found.
