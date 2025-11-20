# Haskell/GHCup configuration

# GHCup binaries (ghcup, ghc, etc.)
path_prepend "$HOME/.ghcup/bin"

# Cabal binaries (Haskell package manager)
path_prepend "$HOME/.cabal/bin"

# Source ghcup environment (but skip PATH modifications since we handle them above)
# This ensures other ghcup environment variables are still set
if [[ -f "$HOME/.ghcup/env" ]]; then
  # Temporarily save PATH
  _OLD_PATH="$PATH"
  source "$HOME/.ghcup/env"
  # Restore PATH to avoid duplicates from ghcup/env
  export PATH="$_OLD_PATH"
  unset _OLD_PATH
fi
