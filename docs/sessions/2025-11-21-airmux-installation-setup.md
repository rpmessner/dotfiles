# Airmux Installation Setup

**Date:** 2025-11-21
**Task:** Get airmux command working and ensure installer sets it up for future installations

## Problem Description

The dotfiles repository referenced `airmux` in the README and had an alias `mux='airmux'` in the aliases file, but airmux was not actually installed anywhere. When trying to use the command, it was not found.

## What is Airmux?

Airmux is a tmux session manager written in Rust that allows you to create and manage tmux sessions via configuration files rather than manual commands. It's a modern alternative to other session managers, providing a declarative way to define tmux layouts and sessions.

- **Repository:** https://github.com/dermoumi/airmux
- **Language:** Rust
- **Installation:** `cargo install airmux`
- **Requirements:** tmux 2.6+, Rust/Cargo

## Investigation & Solution

### Installation Method Decision

Evaluated three potential approaches:
1. **asdf plugin** - No official plugin exists
2. **mise** - Not currently installed in this setup
3. **cargo install** - ✅ Selected approach (standard Rust package installation)

### Implementation Steps

#### 1. Updated tmux Taskfile (`taskfiles/tmux.yml`)

Added two new tasks for airmux installation and updates:

```yaml
airmux:install:
  desc: Install airmux (tmux session manager)
  summary: |
    Install airmux (tmux session manager)

    Airmux is a tmux session manager written in Rust that allows you to
    create and manage tmux sessions via configuration files.

    Requires Rust/cargo to be installed.
  status:
    - command -v airmux
  cmds:
    - cmd: |
        if ! command -v cargo &>/dev/null; then
          echo "⚠️  Cargo not found. Installing Rust first..."
          asdf plugin add rust https://github.com/asdf-community/asdf-rust.git || true
          asdf install rust latest
          asdf global rust latest
          # Reload shell to get cargo in PATH
          export PATH="$HOME/.asdf/installs/rust/$(asdf current rust | awk '{print $2}')/bin:$PATH"
        fi
        echo "📦 Installing airmux via cargo..."
        cargo install airmux
        echo "✅ Airmux installed successfully!"

airmux:update:
  desc: Update airmux to the latest version
  cmds:
    - cmd: |
        if command -v cargo &>/dev/null; then
          echo "📦 Updating airmux..."
          cargo install airmux --force
          echo "✅ Airmux updated successfully!"
        else
          echo "❌ Cargo not found. Cannot update airmux."
          exit 1
        fi
```

**Key Features:**
- Automatically installs Rust if cargo is not available
- Uses status check to skip installation if airmux already exists
- Provides clear user feedback with emoji indicators
- Follows the same pattern as other tool installations (go.yml, rust.yml)

#### 2. Integrated into Main Installation Flow (`taskfiles/dotfiles.yml`)

Added `tmux:airmux:install` to both install and sync tasks:

**Install task (line 97):**
```yaml
- task: tmux:plugins:install
- task: tmux:airmux:install  # Added
- task: gh:plugins:install
```

**Sync task (line 121):**
```yaml
- task: tmux:sync
- task: tmux:airmux:install  # Added
- task: zinit:sync
```

This ensures airmux is installed during:
- Initial setup (`task install`)
- Configuration updates (`task sync`)

#### 3. Fixed PATH Configuration (`zshenv`)

Added cargo bin directory to PATH to make Rust-installed tools accessible:

```bash
# Add cargo bin directory for Rust-installed tools (e.g., airmux)
path_append "$HOME/.cargo/bin"
```

This was added at line 41 in `zshenv`, using the existing `path_append` helper function to avoid duplicates.

## File Locations

### Modified Files
- `taskfiles/tmux.yml` - Added airmux installation tasks (lines 69-105)
- `taskfiles/dotfiles.yml` - Integrated airmux into install/sync flows (lines 97, 121)
- `zshenv` - Added cargo bin to PATH (line 41)

### Existing Files (Unchanged)
- `aliases` - Already has `alias mux='airmux'` (line 254)
- `README.md` - Already references airmux (line 156)

### Installation Artifacts
- Binary: `~/.cargo/bin/airmux`
- Rust installation: `~/.asdf/installs/rust/1.91.1/`

## Usage

### Installation Commands

```bash
# Install airmux manually
task tmux:airmux:install

# Update airmux
task tmux:airmux:update

# Included automatically in:
task install  # Initial setup
task sync     # Updates
```

### Using Airmux

```bash
# Direct command
airmux --version

# Via alias
mux --version

# Start a tmux session (requires .airmux.yml config)
mux start <session-name>
```

## Testing Results

✅ Rust installation: Successfully installed v1.91.1 via asdf
✅ Airmux installation: Successfully installed v0.2.3 via cargo
✅ Binary location: `~/.cargo/bin/airmux`
✅ Version check: `airmux 0.2.3`
✅ PATH configuration: Added to zshenv
✅ Alias exists: `mux='airmux'` in aliases file

## Future Enhancements

### Potential Improvements

1. **Default Configuration**
   - Create a default `.airmux.yml` template in `config/airmux/`
   - Symlink to `~/.airmux.yml` during installation
   - Include common session layouts for this dotfiles setup

2. **Documentation**
   - Add airmux usage examples to README
   - Create session templates for common workflows
   - Document integration with existing tmux setup

3. **Cross-Platform Testing**
   - Verify installation on macOS (primary target)
   - Test on Linux/WSL environments
   - Ensure cargo PATH works across platforms

## Related Files & Documentation

### Taskfiles
- `taskfiles/tmux.yml` - Tmux and airmux installation
- `taskfiles/dotfiles.yml` - Main installation orchestration
- `taskfiles/rust.yml` - Rust development tools (similar pattern)
- `taskfiles/go.yml` - Go tools installation (pattern reference)

### Configuration
- `zshenv` - Shell environment and PATH setup
- `aliases` - Shell aliases including mux

### External Resources
- [Airmux GitHub](https://github.com/dermoumi/airmux)
- [Rust Installation Guide](https://www.rust-lang.org/tools/install)
- [asdf-rust Plugin](https://github.com/asdf-community/asdf-rust)

## Commands for Verification

```bash
# Check if airmux is installed
command -v airmux

# Check version
airmux --version

# Test alias
alias mux

# Verify PATH includes cargo bin
echo $PATH | grep -o "$HOME/.cargo/bin"

# List all cargo-installed binaries
ls -la ~/.cargo/bin/

# Check Rust installation via asdf
asdf current rust
```

## Tags

`#airmux` `#tmux` `#rust` `#cargo` `#installation` `#taskfile` `#automation` `#session-manager`
