# set XDG paths (must be set before zshrc loads)
export XDG_CACHE_HOME="${HOME}/.cache"
export XDG_DATA_HOME="${HOME}/.local/share"
export XDG_CONFIG_HOME="${HOME}/.config"

# Helper function to safely add to PATH (avoid duplicates)
path_prepend() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$1:$PATH" ;;
  esac
}

path_append() {
  case ":$PATH:" in
    *":$1:"*) ;;
    *) export PATH="$PATH:$1" ;;
  esac
}

# Detect Homebrew prefix based on architecture
if [[ -d "/opt/homebrew" ]]; then
  # Apple Silicon
  export BREW_PREFIX="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  # Intel Mac
  export BREW_PREFIX="/usr/local"
else
  # Linux or other
  export BREW_PREFIX="/usr/local"
fi

# ensure dotfiles bin directory is loaded first
path_prepend "$HOME/.bin"
path_prepend "/usr/local/sbin"

# mkdir .git/safe in the root of repositories you trust
path_prepend ".git/safe/../../bin"

# Add cargo bin directory for Rust-installed tools (e.g., airmux)
path_append "$HOME/.cargo/bin"

# Local config
[[ -f ~/.zshenv.local ]] && source ~/.zshenv.local
