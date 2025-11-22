# emacs mode
bindkey -e

bindkey "^A" beginning-of-line
bindkey "^E" end-of-line
bindkey "^K" kill-line
bindkey "^R" history-incremental-search-backward
bindkey "^P" history-search-backward
bindkey "^Y" accept-and-hold
bindkey "^N" insert-last-word

# Bind Option-left-right to previous-next word
bindkey "^[[1;3C" forward-word
bindkey "^[[1;3D" backward-word

bindkey "^[f" forward-word
bindkey "^[b" backward-word

bindkey '^r' history-incremental-search-backward

# zsh-autosuggestions keybindings
# Accept entire suggestion with Ctrl+F (most common use case)
bindkey '^F' autosuggest-accept
# Accept one word at a time with Alt+F or Ctrl+→ (already bound to forward-word above)

# Ctrl+W deletes word backward (like vim, zsh default)
bindkey '^W' backward-kill-word
