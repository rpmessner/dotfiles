# Keybindings configuration for zsh-vi-mode
# This file configures keybindings AFTER zsh-vi-mode initializes.
# ZVM_* config vars (init mode, cursor, escape key) are set in zinitrc, since
# they must be set before the plugin is sourced.
# See: https://github.com/jeffreytse/zsh-vi-mode

# =============================================================================
# Custom keybindings (applied after zsh-vi-mode init via hook)
# =============================================================================

function zvm_after_init() {
  # -------------------------------------------------------------------------
  # Insert mode: Keep essential emacs-style bindings
  # -------------------------------------------------------------------------
  bindkey -M viins '^A' beginning-of-line      # Ctrl+A - start of line
  bindkey -M viins '^E' end-of-line            # Ctrl+E - end of line
  bindkey -M viins '^K' kill-line              # Ctrl+K - delete to end of line
  bindkey -M viins '^D' delete-char            # Ctrl+D - delete char forward
  bindkey -M viins '^W' backward-kill-word     # Ctrl+W - delete word backward
  bindkey -M viins '^U' backward-kill-line     # Ctrl+U - delete to start of line
  bindkey -M viins '^L' clear-screen           # Ctrl+L - clear screen

  # History search
  bindkey -M viins '^R' history-incremental-search-backward  # Ctrl+R - search history
  bindkey -M viins '^P' up-line-or-history     # Ctrl+P - previous history
  bindkey -M viins '^N' down-line-or-history   # Ctrl+N - next history

  # zsh-autosuggestions
  bindkey -M viins '^F' autosuggest-accept     # Ctrl+F - accept entire suggestion
  bindkey -M viins '^Y' forward-word           # Ctrl+Y - accept word by word

  # Ctrl+G to enter normal mode
  zvm_bindkey viins '^G' vi-cmd-mode

  # Arrow key word movement (insert mode)
  bindkey -M viins "^[[1;5C" forward-word      # Ctrl+→ - forward word
  bindkey -M viins "^[[1;5D" backward-word     # Ctrl+← - backward word

  # -------------------------------------------------------------------------
  # Normal mode: Standard vim bindings (mostly defaults, but ensure they work)
  # -------------------------------------------------------------------------
  # hjkl movement is built-in to zsh-vi-mode
  # w, b, e, W, B, E - word movement built-in
  # 0, ^, $ - line position built-in
  # gg, G - document position built-in
  # /, ? - search built-in

  # Additional normal mode bindings
  bindkey -M vicmd '^L' clear-screen           # Ctrl+L - clear screen in normal mode

  # -------------------------------------------------------------------------
  # FZF integration (re-bind after zsh-vi-mode if fzf widgets are available)
  # -------------------------------------------------------------------------
  if (( $+widgets[fzf-history-widget] )); then
    bindkey -M viins '^R' fzf-history-widget
    bindkey -M vicmd '^R' fzf-history-widget
  fi
  if (( $+widgets[fzf-file-widget] )); then
    bindkey -M viins '^T' fzf-file-widget
  fi
}

# =============================================================================
# Lazy keybindings (for plugins that load later)
# =============================================================================

function zvm_after_lazy_keybindings() {
  # Any keybindings for lazily-loaded plugins go here
  :
}
