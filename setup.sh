#!/bin/bash

# Source OS detection
# shellcheck disable=1091
source ./installer/lib/detect-os.sh

# Run shared installation steps
echo 'Installing shared steps...'
./installer/lib/shared.sh

# Run platform-specific installation
case "$PLATFORM" in
  darwin)
    echo 'macOS detected'
    ./installer/platforms/darwin.sh
    ;;
  ubuntu)
    echo 'Ubuntu detected, getting required packages...'
    ./installer/platforms/ubuntu.sh
    ;;
  *)
    echo "ERROR: Unsupported platform detected"
    echo "This installer supports macOS and Ubuntu only"
    echo "Detected: OS=$OS DIST=$DIST PLATFORM=$PLATFORM"
    exit 1
    ;;
esac

task install "$@"
