#!/bin/bash

set -e  # Exit on error

# Function to display error messages
error() {
  echo "❌ ERROR: $1" >&2
  echo "💡 $2" >&2
  exit 1
}

echo 'Configuring macOS settings...'
# disables the hold key menu to allow key repeat
defaults write -g ApplePressAndHoldEnabled -bool false
# The speed of repetition of characters
defaults write -g KeyRepeat -int 2
# Delay until repeat
defaults write -g InitialKeyRepeat -int 15

if ! command -v brew &>/dev/null; then
  echo 'Homebrew not installed, installing...'

  # Check for curl
  if ! command -v curl &>/dev/null; then
    error "curl is not installed" \
          "curl should be pre-installed on macOS. Try reinstalling Command Line Tools."
  fi

  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    error "Failed to install Homebrew" \
          "Check https://brew.sh for troubleshooting. Ensure you have Command Line Tools: 'xcode-select --install'"
  fi

  if ! eval "$(/opt/homebrew/bin/brew shellenv)"; then
    error "Failed to configure Homebrew environment" \
          "Homebrew may have installed to a non-standard location. Check /opt/homebrew/bin/brew"
  fi

  echo "✅ Homebrew installed successfully"
fi

# Install Task (if not already installed)
# Task is required to run the package installation from taskfiles/brew.yml
if ! command -v task &>/dev/null; then
  echo 'Task not installed, installing via Homebrew...'
  if ! brew install go-task; then
    error "Failed to install Task" \
          "Task is required for package management. Try: brew install go-task"
  fi
  echo "✅ Task installed successfully"
fi

echo 'Installing Homebrew packages via Task...'
if ! task brew:sync; then
  error "Failed to install Homebrew packages via Task" \
        "Check Brewfile for issues. Try running 'task brew:sync' manually to see detailed errors."
fi

if ! command -v sudo-touchid &>/dev/null; then
  echo 'Installing Sudo TouchID...'
  curl -# https://raw.githubusercontent.com/artginzburg/sudo-touchid/main/sudo-touchid.sh -o /usr/local/bin/sudo-touchid \
    && chmod +x /usr/local/bin/sudo-touchid \
    && sudo curl -# https://raw.githubusercontent.com/artginzburg/sudo-touchid/main/com.user.sudo-touchid.plist -o /Library/LaunchDaemons/com.user.sudo-touchid.plist \
    && /usr/local/bin/sudo-touchid
fi

# Install TerminalVim
if [[ ! -f "/Applications/TerminalVim.app" ]]; then
  echo 'Installing TerminalVim app'
  cp -r ./iterm/TerminalVim.app /Applications/TerminalVim.app
fi

if [[ ! -f "/Applications/BTop.app" ]]; then
  echo 'Installing BTop app'
  cp -r ./iterm/BTop.app /Applications/BTop.app
fi

# setup file handlers for TerminalVim
terminal_vim_id="$(osascript -e 'id of app "TerminalVim"')"
for ext in md txt js jsx ts tsx json lua rb ex exs eex heex yaml yml plist; do
  echo "Setting TerminalVim as handler for .$ext"
  duti -s "$terminal_vim_id" ".$ext" editor
done
