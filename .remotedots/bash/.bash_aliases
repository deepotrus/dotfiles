alias ..="cd .."
alias hl="history | cut -c 8- | sort | uniq | fzf"
alias h='cmd=$(history | cut -c 8- | sort | uniq | fzf) && [[ -n $cmd ]] && eval "$cmd"'

# show the full list of matches immediately
bind 'set show-all-if-ambiguous on'          # no need to press Tab twice
bind 'set completion-query-items 100'        # show list even if many entries

# menu‑complete for cycling
bind '"\t":menu-complete'                    # Tab = menu‑complete
# Backward (Shift‑Tab) – reverse menu‑complete
#bind '"\e[Z":reverse-menu-complete'   # Escape‑[Z is the code for Shift‑Tab in most terminals
bind '"\e[1;2Z":reverse-menu-complete'   # sometimes used

# make the current match stand out while cycling
bind 'set menu-complete-display-prefix on'   # keep the typed prefix visible

# make completion case‑insensitive
bind 'set completion-ignore-case on'
