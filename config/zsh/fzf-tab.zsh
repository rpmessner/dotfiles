# fzf-tab configuration
# =====================

# Enable Ctrl+K to navigate up in fzf (Ctrl+J for down is default)
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-k:up' 'ctrl-j:down'

# Configure fzf-tab to show more context
zstyle ':fzf-tab:*' fzf-min-height 15

# Enable preview window (right side, 50% width, with border)
zstyle ':fzf-tab:*' fzf-flags --preview-window=right:50%:wrap

# Handle filenames with spaces and special characters properly
# This strips quotes from display but preserves them during insertion
zstyle ':fzf-tab:*' prefix ''

# Use continuous completion for paths (shows preview and handles quotes better)
zstyle ':fzf-tab:*' continuous-trigger '/'

# Show file previews for file/directory completions
# Note: On Ubuntu/Debian, bat is called batcat
zstyle ':fzf-tab:complete:*:*' fzf-preview '[[ -f "$realpath" ]] && (batcat --color=always --style=plain --line-range=:50 "$realpath" 2>/dev/null || bat --color=always --style=plain --line-range=:50 "$realpath" 2>/dev/null || cat "$realpath") || [[ -d "$realpath" ]] && eza --tree --level=1 --color=always "$realpath" 2>/dev/null || echo "Preview not available"'

# Don't add extra escaping - zsh already handles this
zstyle ':completion:*' special-dirs false

# Parse SSH hosts from ~/.ssh/config and set them for completion
# This extracts all "Host" entries (excluding wildcards)
if [[ -r ~/.ssh/config ]]; then
  h=()
  # Read file, filter Host lines, remove "Host " prefix, exclude wildcards
  # Strip both leading/trailing whitespace and carriage returns (for CRLF files)
  h=(${${${${(@M)${(f)"$(<~/.ssh/config)"}:#Host *}#Host }:#*[*?]*}//$'\r'/})
  # Trim any remaining whitespace
  h=(${h//[[:space:]]##/ })
  h=(${h// /})
  zstyle ':completion:*:ssh:*' hosts $h
  zstyle ':completion:*:scp:*' hosts $h
  zstyle ':completion:*:sftp:*' hosts $h
fi

# Enable prefix matching for better SSH host completion
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-name ''

# Preview for SSH hosts (optional - shows the config entry)
zstyle ':fzf-tab:complete:ssh:*' fzf-preview 'echo "SSH Config Entry:" && grep -A 3 "^Host $word" ~/.ssh/config 2>/dev/null'

# Preview for mix tasks - shows the task description
zstyle ':fzf-tab:complete:mix:*' fzf-preview 'mix help $word 2>/dev/null || echo "No help available for: $word"'

# Preview for source/dot commands - shows file contents
zstyle ':fzf-tab:complete:(source|.):*' fzf-preview '[[ -f "$realpath" ]] && (batcat --color=always --style=plain --line-range=:50 "$realpath" 2>/dev/null || bat --color=always --style=plain --line-range=:50 "$realpath" 2>/dev/null || cat "$realpath") || echo "Not a file"'
