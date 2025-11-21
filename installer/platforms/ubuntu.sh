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

echo "Updating apt package index..."
if ! sudo apt update; then
  error "Failed to update apt package index" \
        "Check your internet connection and /etc/apt/sources.list configuration"
fi

echo "Installing required Ubuntu packages..."
if ! sudo apt -y install \
  autoconf \
  autojump \
  automake \
  bat \
  bison \
  build-essential \
  clangd-18 \
  curl \
  fop \
  git \
  global \
  httpie \
  inotify-tools \
  libbz2-dev \
  libclang-18-dev \
  libffi-dev \
  libgl1-mesa-dev \
  libglu1-mesa-dev \
  libmnl-dev \
  liblzma-dev \
  libncurses-dev \
  libncurses5-dev \
  libncursesw5-dev \
  libpng-dev \
  libreadline-dev \
  libsqlite3-dev \
  libssh-dev \
  libssl-dev \
  libwxgtk3.2-dev \
  libxml2-dev \
  libyaml-dev \
  libxml2-utils \
  libxmlsec1-dev \
  m4 \
  openjdk-11-jdk \
  pkg-config \
  postgresql \
  postgresql-client \
  pspg \
  python3-tk \
  ruby \
  squashfs-tools \
  ssh-askpass \
  tk-dev \
  tmux \
  tree \
  universal-ctags \
  unixodbc-dev \
  wx-common \
  xsltproc \
  xz-utils \
  zlib1g-dev \
  zsh; then
  error "Failed to install Ubuntu packages" \
        "Check the error messages above. Some packages may not be available on your Ubuntu version. Try running 'sudo apt update' first."
fi

echo "✅ All Ubuntu packages installed successfully"
