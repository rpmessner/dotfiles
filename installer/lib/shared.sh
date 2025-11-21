#!/usr/bin/env bash

set -e  # Exit on error

# Function to display error messages
error() {
  echo "❌ ERROR: $1" >&2
  echo "💡 $2" >&2
  exit 1
}

# Check for git
if ! command -v git &>/dev/null; then
  error "git is not installed" \
        "Install git first: 'brew install git' (macOS) or 'sudo apt install git' (Ubuntu)"
fi

# Install tmux terminfo
if [[ ! -f "/tmp/terminfo/terminfo.src" ]]; then
  echo 'Installing TMux term info...'
  if ! ./scripts/term.sh; then
    error "Failed to install tmux terminfo" \
          "Check scripts/term.sh for issues. Try running it manually."
  fi
fi

# asdf and Ruby are installed from here because the install script uses features
# of ruby that don't exist on the pre-installed version bundled with the OS
if ! command -v asdf &>/dev/null; then
  echo "Installing ASDF version manager..."

  # Check SSH access to GitHub
  if ! ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
    error "Cannot access GitHub via SSH" \
          "Set up SSH keys: https://docs.github.com/en/authentication/connecting-to-github-with-ssh"
  fi

  if ! git clone git@github.com:asdf-vm/asdf.git ~/.asdf --branch v0.14.1; then
    error "Failed to clone asdf repository" \
          "Check your internet connection and GitHub SSH access"
  fi

  # shellcheck disable=1091
  if ! source "$HOME/.asdf/asdf.sh"; then
    error "Failed to source asdf shell environment" \
          "Check if ~/.asdf/asdf.sh exists and is valid"
  fi

  echo "Adding Ruby plugin to asdf..."
  if ! asdf plugin add ruby; then
    error "Failed to add Ruby plugin to asdf" \
          "Check asdf installation and internet connection"
  fi

  echo "Installing Ruby 3.3.8..."
  # Install Ruby version from .tool-versions to ensure consistency
  if ! asdf install ruby 3.3.8; then
    error "Failed to install Ruby 3.3.8" \
          "Check build dependencies. On macOS: 'brew install openssl readline'. On Ubuntu: 'sudo apt install build-essential libssl-dev libreadline-dev'"
  fi

  if ! asdf global ruby 3.3.8; then
    error "Failed to set Ruby 3.3.8 as global version" \
          "Check asdf installation"
  fi

  echo "✅ ASDF and Ruby installed successfully"
fi
