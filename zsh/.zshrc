zstyle ':omz:update' mode disabled  # disable automatic updates

# export PATH=$HOME/bin:/usr/local/bin:$PATH
ZSH_THEME="alanpeabody"
setopt histignorespace

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"
export PATH="${PATH}:${HOME}/.local/bin/"

alias ..="cd .."
alias sl="ls"
alias ks="ls"
alias jl="jupyter-lab --port 7693"
alias ytaudio="yt-dlp -x --no-playlist"
alias n="newsboat"

# history aliases
alias h='cmd=$(history | cut -c 8- | sort | uniq | fzf -e) && [[ -n $cmd ]] && eval "$cmd"'
alias hc="history | cut -c 8- | sort | uniq | fzf | tr -d '\n' | xclip -selection c"
alias hl="history | cut -c 8- | sort | uniq | fzf"

alias mist="ollama run mistral:7b"
alias seek="ollama run deepseek-r1:14b"

alias s1="ssh lvd@10.1.0.250" # LVPX Chassis
alias s2="ssh lvd@10.1.0.92"  # LVME Chassis
alias s3="ssh lvd@10.1.0.101" # x101 Chassis
alias s4="ssh lvd@10.1.1.94"  # xmc Chassis

(cat ~/.cache/wal/sequences &)

# My stable programs
alias listbig="du -a /home | sort -n -r | head -n 30"
alias fastfetch="/opt/fastfetch-linux-amd64/usr/bin/fastfetch"
#alias nvim="/opt/nvim-linux-x86_64/bin/nvim"
alias vivado="vivado -nolog -nojournal"

catmd() {
  local md_file="$1"
  pandoc --webtex "$md_file" -o /tmp/temp.html
  firefox /tmp/temp.html
}






fcd() {
  cd "$(find /home/$USER -type d | fzf)"
}
sfcd() {
  cd "$(find / -type d | fzf)"
}

# by choosing only the directory it will automatically chose a random image
wal-tile() {
  wal -n -i "$@" # -n is because feh is used for setting background already
  feh --bg-scale "$(< "${HOME}/.cache/wal/wal")"
}

vivavo() {
  . /opt/Xilinx/Vivado/2022.2/settings64.sh
  export _JAVA_AWT_WM_NONREPARENTING=1
  vivado
}

# ------------- ZSH HISTORY MANAGEMENT ----------------

setopt histignorespace
setopt histignorealldups
setopt histreduceblanks

HISTORY_IGNORE="(ls|bg|fg|cd|exit|clear|h|htop|zsh)"
HIST_IGNORE_PATTERN='^(cd|vim)*[[:space:]]*'

plugins=(git)
source ~/.cache/wal/colors-tty.sh
source $ZSH/oh-my-zsh.sh
