zstyle ':omz:update' mode disabled  # disable automatic updates
ZSH_THEME="alanpeabody"

export ZSH="$HOME/.oh-my-zsh"
export PATH="${PATH}:${HOME}/.local/bin/"

# -------------- ALIASES --------------
alias ..="cd .."
alias ...="cd ../.."
alias sl="ls"
alias ks="ls"
alias hx="history | cut -c 8- | sort | uniq | fzf | tr -d '\n' | xclip -selection c"
alias h='cmd=$(history | cut -c 8- | sort | uniq | fzf) && [[ -n $cmd ]] && eval "$cmd"'
alias ytaudio="yt-dlp -x --no-playlist"
alias n="newsboat"
alias vivado="vivado -nolog -nojournal"

# -------------- FUNCTIONS --------------
catmd() {
  local md_file="$1"
  pandoc --webtex "$md_file" -o /tmp/temp.html
  firefox /tmp/temp.html
}

# by choosing only the directory it will automatically chose a random image
wal-tile() {
  wal -n -i "$@" # -n is because feh is used for setting background already
  feh --bg-scale "$(< "${HOME}/.cache/wal/wal")"
}

# ------------- HISTORY MANAGEMENT ----------------
setopt histignorespace
setopt histignorealldups
setopt histreduceblanks
HISTORY_IGNORE="(ls|bg|fg|cd|exit|clear|h|htop|zsh)"

#source ~/.cache/wal/colors-tty.sh
(cat ~/.cache/wal/sequences &)

plugins=(git)
source $ZSH/oh-my-zsh.sh
