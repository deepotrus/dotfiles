zstyle ':omz:update' mode disabled  # disable automatic updates
ZSH_THEME="alanpeabody"

export ZSH="$HOME/.oh-my-zsh"
export PATH="${PATH}:${HOME}/.local/bin/"

# -------------- ALIASES --------------
alias ..="cd .."
alias ...="cd ../.."
alias sl="ls"
alias ks="ls"
alias h='cmd=$(history | cut -c 8- | sort | uniq | fzf) && [[ -n $cmd ]] && eval "$cmd"'

# ------------- HISTORY MANAGEMENT ----------------
setopt histignorespace
setopt histignorealldups
setopt histreduceblanks
HISTORY_IGNORE="(ls|bg|fg|cd|exit|clear|h|htop|zsh)"

plugins=(git)
source $ZSH/oh-my-zsh.sh
