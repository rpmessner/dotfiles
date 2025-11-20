# asdf version manager
# https://asdf-vm.com

# Detect installation method and source appropriately
if [[ -f "$HOME/.asdf/asdf.sh" ]]; then
  # Direct installation (Linux, manual install)
  source "$HOME/.asdf/asdf.sh"
elif command -v brew &> /dev/null && [[ -f "$(brew --prefix asdf)/libexec/asdf.sh" ]]; then
  # Homebrew installation (macOS)
  . "$(brew --prefix asdf)/libexec/asdf.sh"
fi

# Prepend asdf shims to PATH to ensure they take priority over system binaries
path_prepend "$HOME/.asdf/shims"

export ASDF_GOLANG_MOD_VERSION_ENABLED=true
