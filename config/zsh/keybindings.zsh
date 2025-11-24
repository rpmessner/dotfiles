# emacs mode
bindkey -e

# Keep useful emacs bindings
bindkey "^A" beginning-of-line      # Ctrl+A - start of line (emacs/tmux compatible)
bindkey "^E" end-of-line            # Ctrl+E - end of line (emacs compatible)
bindkey "^R" history-incremental-search-backward  # Ctrl+R - search history
bindkey "^P" history-search-backward  # Ctrl+P - previous in history
bindkey "^Y" accept-and-hold        # Ctrl+Y - yank/paste
bindkey "^N" insert-last-word       # Ctrl+N - insert last word

# Vim-like navigation using Alt+ (doesn't conflict with essential Ctrl+ bindings)
# Character movement (hjkl)
bindkey '^[h' backward-char         # Alt+H - move left (like h in vim)
bindkey '^[l' forward-char          # Alt+L - move right (like l in vim)
bindkey '^[k' up-line-or-history    # Alt+K - move up (like k in vim)
bindkey '^[j' down-line-or-history  # Alt+J - move down (like j in vim)

# Word movement (vim w/b)
bindkey '^W' backward-kill-word     # Ctrl+W - delete word backward (vim default)
bindkey '^[w' forward-word          # Alt+W - forward word (like w in vim)
bindkey '^[b' backward-word         # Alt+B - backward word (like b in vim)
bindkey '^[f' forward-word          # Alt+F - forward word (alternate)

# Arrow key word movement
bindkey "^[[1;3C" forward-word      # Alt+→ - forward word
bindkey "^[[1;3D" backward-word     # Alt+← - backward word

# Line operations (keep standard emacs/zsh defaults)
bindkey '^K' kill-line              # Ctrl+K - delete to end of line (standard)
bindkey '^L' clear-screen           # Ctrl+L - clear screen (standard)

# zsh-autosuggestions keybindings
bindkey '^F' autosuggest-accept     # Ctrl+F - accept entire suggestion
