# WSL2 Ubuntu 24.04 Installation Session

**Date**: November 20, 2025
**Platform**: WSL2 (Windows Subsystem for Linux)
**Distribution**: Ubuntu 24.04.3 LTS (Noble Nobleman)

---

## Overview

First-time installation of dotfiles on a fresh WSL2 Ubuntu 24.04 environment. This document records all issues encountered and fixes applied to improve future installations on Ubuntu/WSL2.

---

## Issues Encountered & Fixes Applied

### 1. Platform Detection - Ubuntu vs Generic Debian

**Issue**: Setup script only detected "Debian-based" distro and used `debian-setup.sh`, which had outdated package versions for Ubuntu 24.04.

**Solution**:
- Created `installer/ubuntu-setup.sh` with Ubuntu 24.04-specific packages
- Updated `setup.sh` to detect Ubuntu specifically before falling back to generic Debian
- Updated packages:
  - `clangd-13` → `clangd-18`
  - `libclang-13-dev` → `libclang-18-dev`
  - `libwxgtk3.0-gtk3-dev` → `libwxgtk3.2-dev`
  - Added missing: `libyaml-dev` (required for Ruby psych extension)

**Files Modified**:
- Created: `installer/ubuntu-setup.sh`
- Modified: `setup.sh` (lines 50-59)

**Recommendation**: Consider checking `lsb_release -si` for more accurate distro detection.

---

### 2. SSH Keys Not Configured

**Issue**: `installer/shared.sh` tries to clone asdf via SSH (`git@github.com:asdf-vm/asdf.git`) but SSH keys weren't set up yet.

**Solution**:
- Generated ED25519 SSH key with user's email
- Added to GitHub account
- Added GitHub to known_hosts

**Not Fixed Yet**: The installer should either:
  - Check for SSH access and fall back to HTTPS if unavailable
  - Include SSH setup in the installation flow (prompt for email, generate key, display for user to add to GitHub)
  - Use HTTPS by default and document SSH setup separately

**Recommendation**: Add interactive SSH key setup:
  - Prompt user for email address (for SSH key comment)
  - Generate key if none exists
  - Display public key for user to add to GitHub
  - Wait for user confirmation before proceeding
  - Or use HTTPS URLs by default

---

### 3. ASDF Version Mismatch

**Issue**: Installer cloned latest asdf (v0.16.0), which is a Go rewrite. The `asdf set -p` command doesn't exist in any version.

**Solution**:
- Pinned asdf to stable v0.14.1 in `installer/shared.sh`
- Changed `asdf set -p ruby 3.3.8` → `asdf global ruby 3.3.8`

**Files Modified**:
- `installer/shared.sh` (line 12, 18)

**Recommendation**: Pin to stable version and update periodically rather than using latest.

---

### 4. Missing libyaml-dev Package

**Issue**: Ruby 3.3.8 build failed - psych extension couldn't compile due to missing libyaml-dev.

**Solution**: Added `libyaml-dev` to `installer/ubuntu-setup.sh`

**Files Modified**:
- `installer/ubuntu-setup.sh` (added line 38)

**Recommendation**: Already fixed in the ubuntu-setup.sh installer.

---

### 5. Task Runner Not Installed

**Issue**: `setup.sh` calls `task install` at the end, but Task wasn't installed yet.

**Solution**: Installed Task manually to `~/.local/bin` before running setup.

**Not Fixed**: The installer should install Task as a dependency.

**Recommendation**: Add Task installation to `installer/shared.sh` or early in the setup process.

---

### 6. ASDF Task Not Idempotent

**Issue**: Running `task dot:install` multiple times failed because asdf task tried to re-clone asdf repo.

**Solution**: Added `status` check to `taskfiles/asdf.yml` to skip if already installed.

**Files Modified**:
- `taskfiles/asdf.yml` (added lines 8-9)

**Recommendation**: Already fixed - all task installation steps should follow this pattern.

---

### 7. Shell Change Requires Password

**Issue**: `task dot:install` requires interactive password input to change default shell to zsh, breaking automation.

**Solution**: User manually ran `chsh -s $(which zsh)` before running tasks.

**Not Fixed**: Task installation isn't fully non-interactive.

**Recommendation**:
- Document that user needs to run `chsh` manually first
- Or skip the shell change and document it as post-installation step
- Or use `sudo` with better error messaging

---

### 8. ASDF Plugins Not Pre-installed

**Issue**: Running `asdf install` fails because plugins aren't added yet.

**Solution**: Manually added plugins before running `asdf install`:
```bash
asdf plugin add elixir
asdf plugin add erlang
asdf plugin add lua-language-server
asdf plugin add nodejs
asdf plugin add rebar
```

**Not Fixed**: The task should auto-add plugins based on .tool-versions.

**Recommendation**: Create a task that parses `.tool-versions` and adds all plugins automatically, or add plugins explicitly in the asdf task.

---

### 9. Erlang Build Lock File

**Issue**: Previous interrupted Erlang build left a lock file, preventing new builds.

**Solution**: Removed lock file manually:
```bash
rm -rf ~/.asdf/installs/erlang/.kerl/builds/asdf_28.1.1
```

**Recommendation**: Add cleanup check in asdf task, or document common build issues.

---

### 10. wxWebView Warning on WSL2

**Issue**: Erlang build shows warning: "wxWebView is not installed, so wxWebView will not be available"

**Status**: Expected behavior - WSL2 doesn't have GUI libraries installed by default.

**Impact**: Erlang GUI tools (Observer, Debugger) won't work without X server setup (VcXsrv or WSLg).

**Recommendation**: Document this in WSL2-specific notes. Most development work doesn't need GUI tools.

---

### 11. Outdated Tool Versions

**Issue**: `.tool-versions` had slightly outdated versions.

**Solution**: Updated to latest stable versions as of November 2025:
- `elixir 1.19.3-otp-27` → `1.19.3-otp-28`
- `nodejs 23.11.0` → `24.11.0` (LTS)
- `lua-language-server 3.5.6` → `3.15.0`
- `ruby 3.3.8` → `3.4.7`

**Files Modified**:
- `.tool-versions`

**Recommendation**: Set up automated dependency updates (Renovate, Dependabot) or document update process.

---

## Platform-Specific Notes: WSL2

### What Works
- All CLI tools and development environments
- Git, SSH, zsh, tmux
- asdf and language runtimes (Node, Ruby, Elixir, Erlang)
- File system access to Windows via `/mnt/c/`, `/mnt/d/`, etc.

### What Doesn't Work (Out of Box)
- Erlang GUI tools (Observer, Debugger) - requires X server
- Display/GUI applications - requires WSLg or X server (VcXsrv)

### WSL2-Specific Considerations
- Windows filesystem access: `/mnt/c/Users/<windows-username>/...`
- Better performance keeping files in Linux filesystem (`~/`)
- systemd available in Ubuntu 24.04+ on WSL2
- Windows Terminal or WezTerm recommended for terminal emulator

---

## Installation Flow (Corrected Order)

For future seamless Ubuntu/WSL2 installations:

1. **Prerequisites** (before running setup.sh):
   - SSH keys generated and added to GitHub (if using SSH URLs)
   - Or use HTTPS URLs for git clones

2. **Run installer**:
   ```bash
   ./setup.sh
   ```
   This should:
   - Detect Ubuntu and run `ubuntu-setup.sh`
   - Install apt packages (including libyaml-dev)
   - Install asdf (v0.14.1)
   - Install Ruby via asdf
   - Install Task runner
   - Prompt user to change shell (or skip)

3. **Manual step** (until automated):
   ```bash
   chsh -s $(which zsh)
   ```

4. **Complete installation**:
   ```bash
   task dot:install
   ```
   This should:
   - Auto-add asdf plugins based on .tool-versions
   - Install all tools
   - Install zinit and zsh plugins
   - Install tmux plugins
   - Symlink all dotfiles

5. **Restart shell** to load new config

---

## User Information Prompts Needed

To make the installation work across different usernames and platforms, add prompts for:

### During Initial Setup (setup.sh or pre-flight script)

1. **Email Address** (for SSH keys and git config)
   ```bash
   read -p "Enter your email address: " USER_EMAIL
   ```
   Used for:
   - SSH key generation comment
   - Git user.email configuration

2. **Full Name** (for git commits)
   ```bash
   read -p "Enter your full name: " USER_NAME
   ```
   Used for:
   - Git user.name configuration

3. **GitHub Username** (optional, for SSH setup)
   ```bash
   read -p "Enter your GitHub username (optional): " GITHUB_USER
   ```
   Used for:
   - Displaying SSH key setup instructions
   - Potentially cloning repos

### Where to Store User Config

**Note**: The gitconfig already uses this pattern - it includes `~/.gitconfig.local` at the end.

Create `~/.gitconfig.local` during installation to store:
```gitconfig
[user]
    name = User Name
    email = user@example.com
```

Additionally, create `~/.dotfiles.local` for shell-based user config:
```bash
export USER_EMAIL="user@example.com"
export USER_NAME="User Name"
export GITHUB_USER="username"
```

These files should be:
- Created during installation
- Gitignored (pattern `*.local` added to .gitignore)
- The gitconfig.local is already included by gitconfig
- The dotfiles.local can be sourced by installation scripts

### Implementation Plan

1. Add pre-flight script that:
   - Checks if `~/.dotfiles.local` exists
   - If not, prompts for user information
   - Saves to `~/.dotfiles.local`
   - Sources it for rest of installation

2. Update `gitconfig` to use variables:
   ```gitconfig
   [user]
       name = ${USER_NAME}
       email = ${USER_EMAIL}
   ```
   Or use conditional includes

3. Update SSH key generation to use `$USER_EMAIL`

4. Document in README that these prompts will occur

---

## Recommended Improvements

### High Priority
1. **Add Task installation** to `installer/shared.sh`
2. **Auto-detect and add asdf plugins** from `.tool-versions`
3. **Check for SSH access** and fall back to HTTPS or prompt user
4. **Add libyaml-dev** to debian-setup.sh too (not just Ubuntu)

### Medium Priority
5. **Make shell change optional/documented** rather than required
6. **Add pre-flight checks** (git, curl, build-essential)
7. **Better error messages** when dependencies are missing
8. **Idempotent all tasks** (following asdf.yml pattern)

### Low Priority
9. **Add cleanup for interrupted builds** (Erlang lock files, etc.)
10. **Document WSL2-specific setup** (X server for GUI tools)
11. **Automated version updates** for `.tool-versions`

---

## Files Modified During Installation

### Created
- `installer/ubuntu-setup.sh`
- `docs/sessions/2025-11-20-wsl2-ubuntu-installation.md` (this file)

### Modified
- `setup.sh` - Added Ubuntu detection
- `installer/shared.sh` - Pinned asdf version, fixed asdf global command
- `taskfiles/asdf.yml` - Added idempotent status check
- `.tool-versions` - Updated to latest stable versions

---

## Success Criteria Met

After installation completion:
- ✅ All dotfiles properly symlinked
- ✅ zsh set as default shell
- ✅ asdf installed with all language runtimes
- ✅ Git configured
- ⏳ zinit and zsh plugins (in progress)
- ⏳ tmux plugins (pending)
- ⏳ Shell loads without errors (pending plugin installation)

---

## Next Steps for Future Installations

1. Incorporate fixes into main branch
2. Test on fresh Ubuntu 24.04 VM to verify seamless installation
3. Add CI/CD to test installation on multiple platforms
4. Document platform-specific quirks (macOS vs Linux vs WSL2)
5. Consider creating platform-specific setup scripts

---

## Terminal Setup (WezTerm on WSL2)

### Installation
- Install WezTerm on Windows: `winget install wez.wezterm`
- Desktop shortcut target: `"C:\Program Files\WezTerm\wezterm-gui.exe" start -- wsl.exe -d Ubuntu-24.04`

### Notes
- WezTerm config already present in dotfiles at `~/.config/wezterm/`
- Automatically loads zsh with full dotfiles configuration
- Access Windows filesystem via `/mnt/c/`, etc.

---

## Contact & Context

This installation was assisted by Claude Code. For questions or improvements, refer to:
- Main documentation: `docs/`
- CLAUDE.md for Claude Code integration guide
- This session document for platform-specific issues
