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

# Install asdf version manager
# Language runtimes (Ruby, Python, Node, etc.) are installed via 'task asdf:tools:install'
# which reads from .tool-versions file
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

  echo "✅ ASDF installed successfully"
  echo "ℹ️  Language runtimes will be installed via 'task asdf:tools:install'"
fi
