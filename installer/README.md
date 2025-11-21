# Dotfiles Installer

This directory contains the **bootstrap layer** of the dotfiles installation system.

## Architecture Overview

The dotfiles installation uses a **two-phase architecture**:

### Phase 1: Bootstrap (This Directory)
Handles system-level prerequisites that are required before Task can run:
- OS detection and validation
- System package managers (Homebrew, apt)
- Essential system packages
- ASDF version manager
- Platform-specific system configuration

### Phase 2: Orchestration (Taskfile)
Handles all application-level installation and configuration:
- Dotfile symlinking
- Tool installation via ASDF
- Application configuration
- Font installation
- Shell setup

**Entry Point**: `./setup.sh` in repository root

## Directory Structure

```
installer/
├── platforms/          # Platform-specific bootstrap scripts
│   ├── darwin.sh      # macOS setup (Homebrew, system preferences, apps)
│   └── ubuntu.sh      # Ubuntu setup (apt packages, system libraries)
└── lib/               # Shared utilities and libraries
    ├── detect-os.sh   # OS detection and platform normalization
    ├── shared.sh      # Cross-platform setup (ASDF, tmux terminfo)
    ├── gitconfig.sh   # Git configuration installer
    └── title.txt      # ASCII art banner
```

## Execution Flow

1. **`setup.sh`** (repository root)
   - Sources `lib/detect-os.sh` to detect OS and set `$PLATFORM` variable
   - Runs `lib/shared.sh` for cross-platform prerequisites
   - Routes to platform-specific script based on `$PLATFORM`:
     - `platforms/darwin.sh` for macOS
     - `platforms/ubuntu.sh` for Ubuntu
   - Calls `task install` to complete installation

2. **`lib/detect-os.sh`**
   - Detects operating system using `uname`
   - Normalizes to `$PLATFORM` variable: `darwin` or `ubuntu`
   - Validates platform support (errors on unsupported systems)
   - Exports: `$OS`, `$DIST`, `$DISTRO_BASE`, `$PLATFORM`, `$KERNEL`, `$MACH`

3. **`lib/shared.sh`**
   - Installs tmux terminfo for proper terminal support
   - Installs ASDF version manager (required for Task and other tools)
   - Installs Ruby 3.3.8 via ASDF (required by some dotfiles scripts)

4. **Platform Scripts**

   **`platforms/darwin.sh`** (macOS):
   - Symlinks 1Password SSH agent for cross-platform compatibility
   - Disables macOS press-and-hold, enables key repeat
   - Installs Homebrew if missing
   - Runs `brew bundle` to install all Brewfile packages
   - Installs sudo-touchid for Touch ID sudo authentication
   - Installs unicornleap (requires Xcode)
   - Installs TerminalVim and BTop applications
   - Configures file handlers for TerminalVim

   **`platforms/ubuntu.sh`** (Ubuntu):
   - Installs all required system packages via apt
   - Includes development libraries for Ruby, Python, Node.js, Erlang
   - Installs build tools, compilers, and system utilities
   - Compatible with Ubuntu 24.04 LTS and later
   - Works on bare metal and WSL2

## Supported Platforms

- **macOS** (darwin) - Primary target, fully supported
- **Ubuntu** - 24.04 LTS and later, fully supported
- **Debian** - Detected as Ubuntu for compatibility
- **Other Linux** - Not supported

## Usage

### Fresh Installation

```bash
git clone git@github.com:rpmessner/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./setup.sh
```

The script will:
1. Detect your operating system
2. Install system prerequisites
3. Run the complete Task-based installation
4. Configure your environment

### Re-running After Changes

If you've updated the installer scripts:

```bash
./setup.sh
```

To skip bootstrap and only run Task installation:

```bash
task install
```

To update tools and sync configurations without reinstalling:

```bash
task sync
```

## Dependencies

### Bootstrap Phase Dependencies
- **macOS**: None (installs Homebrew)
- **Ubuntu**: apt package manager (pre-installed)

### Installed by Bootstrap
- ASDF version manager
- Ruby 3.3.8 (via ASDF)
- System package manager packages
- Platform-specific tools

### Requires Manual Installation
- **macOS**: Xcode (for unicornleap compilation)
- **Git SSH keys**: For private repository access

## Design Principles

1. **Idempotent**: Safe to run multiple times
2. **Fail-fast**: Exit on errors with clear messages
3. **Platform-aware**: Different code paths for different OS
4. **Minimal dependencies**: Only requires bash and system package manager
5. **Single responsibility**: Bootstrap handles system, Task handles applications

## Troubleshooting

### "Unsupported platform detected"
Only macOS and Ubuntu are supported. Check `$PLATFORM` output for detected OS.

### "command not found: brew" (after darwin.sh)
The Homebrew installation requires restarting your shell or sourcing the shellenv.

### ASDF installation fails
Ensure you have git installed and SSH keys configured for GitHub access.

### Ubuntu package installation fails
Run `sudo apt update` before installation. Ensure you're on Ubuntu 24.04 or later.

## Historical Context

This installer was refactored in November 2025 to remove dead Ruby installer code (~500 lines) and clarify the bootstrap vs orchestration separation. Previously, there were three parallel installation mechanisms. Now there are two clean layers with clear responsibilities.

See `docs/sessions/2025-11-21-installer-refactoring.md` for full refactoring details.
