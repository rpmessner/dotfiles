#!/usr/bin/env bash

if [[ ! -f "/tmp/terminfo/terminfo.src" ]]; then
  echo 'Installing TMux term info...'
  ./scripts/term.sh
fi

# asdf and Ruby are installed from here because the install script uses features
# of ruby that don't exist on the pre-installed version bundled with the OS
if ! command -v asdf &>/dev/null; then
  echo "Installing ASDF"
  git clone git@github.com:asdf-vm/asdf.git ~/.asdf --branch v0.14.1
  # shellcheck disable=1091
  source "$HOME/.asdf/asdf.sh"
  asdf plugin add ruby
  # Install Ruby version from .tool-versions to ensure consistency
  asdf install ruby 3.3.8
  asdf global ruby 3.3.8
fi
