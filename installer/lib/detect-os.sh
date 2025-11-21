#!/bin/bash

# DETECT OS
# Shamelessly copied from stackoverflow:
# https://stackoverflow.com/questions/394230/how-to-detect-the-os-from-a-bash-script
# =================================================================================
lowercase() {
  echo "$1" | sed "y/ABCDEFGHIJKLMNOPQRSTUVWXYZ/abcdefghijklmnopqrstuvwxyz/"
}

OS="$(lowercase "$(uname)")"
KERNEL="$(uname -r)"
MACH="$(uname -m)"

if [ "${OS}" = "darwin" ]; then
  OS='mac'
else
  OS="$(uname)"
  if [ "${OS}" = "Linux" ]; then
    if [ -f /etc/debian_version ]; then
      DISTRO_BASE='debian'
      DIST=$(grep '^DISTRIB_ID' </etc/lsb-release | awk -F= '{ print $2 }')
    fi
    if [ -f /etc/UnitedLinux-release ]; then
      DIST="${DIST}[$(tr "\n" ' ' </etc/UnitedLinux-release | sed s/VERSION.*//)]"
    fi
    OS="$(lowercase "$OS")"
    readonly OS
    readonly DIST
    readonly DISTRO_BASE
    readonly KERNEL
    readonly MACH
  fi

fi

# Set normalized PLATFORM variable for use in setup scripts
if [ "$OS" = "mac" ]; then
  PLATFORM="darwin"
elif [ "$DIST" = "Ubuntu" ]; then
  PLATFORM="ubuntu"
else
  PLATFORM="unsupported"
fi

readonly PLATFORM

echo
echo "==========================================="
echo "OS: $OS"
echo "DISTRO_BASE: $DISTRO_BASE"
echo "DIST: $DIST"
echo "PLATFORM: $PLATFORM"
echo "KERNEL: $KERNEL"
echo "MACH: $MACH"
echo "==========================================="
echo
