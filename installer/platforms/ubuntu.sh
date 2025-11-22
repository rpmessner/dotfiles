#!/bin/bash

set -e  # Exit on error

# Function to display error messages
error() {
  echo "❌ ERROR: $1" >&2
  echo "💡 $2" >&2
  exit 1
}

# Install all Ubuntu packages needed for dotfiles
# Compatible with Ubuntu 24.04 LTS (Noble) and later
# Works on both bare metal and WSL2

# Install Task (if not already installed)
# Task is required to run the package installation from taskfiles/apt.yml
if ! command -v task &>/dev/null; then
  echo 'Task not installed, installing...'

  # Check for curl
  if ! command -v curl &>/dev/null; then
    echo "Installing curl first..."
    if ! sudo apt update && sudo apt install -y curl; then
      error "Failed to install curl" \
            "curl is required to install Task. Try: sudo apt update && sudo apt install -y curl"
    fi
  fi

  # Install Task using official install script
  # This installs to ~/.local/bin/task (user-local, no sudo needed)
  if ! sh -c "$(curl --location https://taskfile.dev/install.sh)" -- -d -b ~/.local/bin; then
    error "Failed to install Task" \
          "Check https://taskfile.dev for manual installation instructions."
  fi

  # Ensure ~/.local/bin is in PATH for this session
  export PATH="$HOME/.local/bin:$PATH"

  echo "✅ Task installed successfully"
fi

# Delegate package installation to Task
# This uses the package list defined in taskfiles/apt.yml
# Similar to how darwin.sh uses 'task brew:sync' for Homebrew
echo "Installing Ubuntu packages via Task..."
if ! task apt:sync; then
  error "Failed to install Ubuntu packages via Task" \
        "Check taskfiles/apt.yml for issues. Try running 'task apt:sync' manually."
fi

echo "✅ Ubuntu bootstrap complete"
