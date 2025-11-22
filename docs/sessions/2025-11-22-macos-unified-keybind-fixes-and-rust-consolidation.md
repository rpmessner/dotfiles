# macOS Unified Keybind Architecture Fixes and Rust Tooling Consolidation

**Date:** 2025-11-22
**Status:** Complete
**Related:** 2025-11-22-zsh-stty-ctrl-z-fixes.md

## Summary

Debugged and fixed unified keybind architecture issues on macOS, consolidated Rust tooling installation, cleaned up unused packages, and updated to modern asdf command syntax. All changes documented in 16 granular conventional commits.

### Major Changes
1. Fixed tmux Ctrl+S prefix not working on macOS
2. Fixed zsh not launching in new tmux panes
3. Made WezTerm window decorations platform-specific
4. Fixed cargo-watch build failure on macOS arm64
5. Updated all asdf commands to modern syntax
6. Consolidated airmux installation into Rust taskfile
7. Cleaned up unused Homebrew packages and 1Password CLI
8. Made lolcrab optional with graceful fallbacks

## Problem 1: Tmux Ctrl+S Prefix Not Working on macOS

### Issue

After implementing unified keybind architecture, Ctrl+S as the tmux primary prefix was not working on macOS, while Ctrl+Z (secondary prefix) worked fine. Same configuration worked perfectly on Ubuntu WSL2.

### Investigation

**Initial hypothesis:** Keybinding conflicts in tmux.conf

Found conflicting bindings at lines 163 and 178-182:

```tmux
# Line 163 - conflicted with prefix
bind C-s choose-tree

# Lines 178-182 - rebinding Ctrl+S to send secondary prefix instead of primary
bind-key C-b send-prefix
bind-key C-s send-prefix -2
```

**After removing conflicts:** Ctrl+S still didn't work

**Root cause discovered:** Terminal flow control (ixon) was blocking Ctrl+S at the terminal level.

```bash
❯ stty -a | grep ixon
iflags: -istrip icrnl -inlcr -igncr ixon -ixoff ixany imaxbel iutf8
```

The `ixon` flag (enabled) meant Ctrl+S was triggering XON/XOFF flow control instead of reaching tmux.

### Solution

**File:** `config/tmux/tmux.conf`

```tmux
# Removed conflicting keybindings (lines 163, 178-182)
# Changed from:
bind C-s choose-tree
bind-key C-b send-prefix
bind-key C-s send-prefix -2

# To:
bind w choose-tree  # Use w instead, avoiding conflict with split (s)
# (removed other conflicting bindings)
```

**File:** `config/zsh/settings.zsh` (already had the fix)

```zsh
# Disable terminal flow control (Ctrl+S/Ctrl+Q) to allow Ctrl+S as tmux prefix
if [[ -t 0 ]]; then
  stty -ixon
fi
```

**Required:** Run `exec zsh` to apply stty settings in active shell

**Why it worked on WSL2 but not macOS:** The stty settings needed a fresh shell session to apply. After running `exec zsh`, Ctrl+S worked perfectly on macOS.

**Commits:**
- `417c12f` - fix(tmux): fix Ctrl+S prefix and zsh shell issues

## Problem 2: Zsh Not Launching in New Tmux Panes

### Issue

After the initial tmux fixes, new tmux panes and windows were launching bash instead of zsh. The user's prompt showed `MacBookPro:dev ryanmessner$` (bash) instead of the configured powerline prompt (zsh).

### Root Cause

Two issues:

1. **Line 13 of tmux.conf** used `run-shell` with shell substitution:
```tmux
run-shell "tmux set-option -g default-shell $(which zsh)"
```
This had timing issues where the shell substitution happened at config read time, not execution time.

2. **Plugin override:** The `tmux-sensible` plugin was setting `default-command`:
```bash
❯ tmux show-option -g default-command
default-command "reattach-to-user-namespace -l /bin/sh"
```

The `default-command` setting overrides `default-shell`, forcing new panes to use `/bin/sh`.

### Solution

**File:** `config/tmux/tmux.conf`

```tmux
# Line 13 - Changed from run-shell to direct path
# Before:
run-shell "tmux set-option -g default-shell $(which zsh)"

# After:
set-option -g default-shell /opt/homebrew/bin/zsh

# Added at end of file (line 283) - Override plugin-set default-command
# This runs after TPM initialization
set-option -g default-command ""
```

**Why this works:**
- Direct path assignment avoids shell substitution timing issues
- Setting `default-command` to empty string after plugins load prevents tmux-sensible from overriding the shell
- New panes now correctly launch zsh with full powerline prompt

**Testing:**
```bash
tmux new-window 'echo "Shell: $SHELL"; ps -p $$'
# Shows zsh correctly
```

**Commits:**
- `417c12f` - fix(tmux): fix Ctrl+S prefix and zsh shell issues

## Problem 3: macOS Window Buttons Overlapping WezTerm Tabs

### Issue

On macOS, the window control buttons (close/minimize/maximize) were overlapping the bottom of the WezTerm title bar, covering Neovim buffer tabs.

### Solution

Made window decorations platform-specific using the existing `is_macos` variable.

**File:** `config/wezterm/wezterm.lua`

```lua
-- Before (line 59):
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'

-- After:
-- macOS: No buttons (prevents overlap with tab bar)
-- Windows/Linux: Full decorations with buttons
config.window_decorations = is_macos and 'RESIZE' or 'INTEGRATED_BUTTONS|RESIZE'

-- Also increased tab bar font size for better readability (line 77):
font_size = 11.0,  -- was 10.0
```

**Result:** Clean title bar on macOS with no overlap, while preserving window buttons on other platforms.

**Commits:**
- `d7eded0` - feat(wezterm): make window decorations platform-specific

## Problem 4: Cargo-Watch Build Failure on macOS arm64

### Issue

When running `task rust:tools:install`, cargo-watch failed to build from source:

```
error: linking with `cc` failed: exit status: 1
= note: Undefined symbols for architecture arm64:
          "_OBJC_CLASS_$_NSImage", referenced from:
               in libmac_notification_sys-e76236d51a5295eb.rlib
        ld: symbol(s) not found for architecture arm64
```

### Root Cause

The `mac-notification-sys` dependency (used by cargo-watch) has a known issue on macOS arm64 where it's missing the AppKit framework linkage during compilation.

### Solution

Use Homebrew's precompiled binary on macOS, build from source on Linux.

**File:** `taskfiles/rust.yml`

```yaml
tools:install:
  desc: Installs common Rust development tools via cargo
  cmds:
    - cargo install cargo-edit
    # cargo-watch has issues building from source on macOS arm64, use Homebrew instead
    - cmd: brew install cargo-watch
      platforms: [darwin]
    - cmd: cargo install cargo-watch
      platforms: [linux]
    - cargo install cargo-outdated
    # ... other tools
```

**Commits:**
- `54803d8` - fix(rust): use Homebrew for cargo-watch on macOS

## Problem 5: Deprecated asdf Commands

### Issue

Multiple taskfiles were using deprecated `asdf global` and `asdf update` commands that were removed in asdf 0.18.0:

```bash
❯ asdf global rust latest
invalid command provided: global
```

### Solution

Updated all language taskfiles to use modern asdf syntax.

**Files affected:**
- `taskfiles/asdf.yml`
- `taskfiles/rust.yml`
- `taskfiles/ruby.yml`
- `taskfiles/python.yml`
- `taskfiles/node.yml`
- `taskfiles/go.yml`
- `taskfiles/elixir.yml`
- `taskfiles/erlang.yml`
- `taskfiles/tmux.yml`

**Changes:**

1. **Replace `asdf global` with `asdf set`:**
```yaml
# Before:
- asdf global rust latest

# After:
- asdf set rust latest
```

2. **Replace `asdf update` with platform-specific commands:**

**File:** `taskfiles/asdf.yml`

```yaml
update:
  desc: Updates asdf itself
  cmds:
    # macOS: Update via Homebrew
    - cmd: brew upgrade asdf || true
      platforms: [darwin]
      silent: true

    # Linux: Update via git if installed to ~/.asdf
    - cmd: |
        if [[ -d ~/.asdf/.git ]]; then
          cd ~/.asdf && git pull
        fi
      platforms: [linux]
      silent: true

    # Update all plugins
    - cmd: asdf plugin update --all
      silent: true
```

**Commits:**
- `1d6c29d` - fix(taskfiles): update to modern asdf command syntax

## Refactor 1: Consolidate Airmux Installation

### Issue

Airmux (tmux session manager written in Rust) had its own installation task in `taskfiles/tmux.yml` that would auto-install Rust if needed. This violated the on-demand language installation philosophy.

### Solution

Moved airmux installation to `rust:tools:install` since it's a Rust tool and doesn't make sense to install without Rust.

**File:** `taskfiles/rust.yml`

```yaml
tools:install:
  desc: Installs common Rust development tools via cargo
  cmds:
    - cargo install cargo-edit
    - cargo install cargo-watch  # (platform-specific as above)
    # ... other tools
    - cargo install airmux
    - asdf reshim rust  # Make new binaries available
```

**File:** `taskfiles/tmux.yml`

Removed 44 lines of airmux installation code:
- `airmux:install` task
- `airmux:update` task
- Auto-installation logic with Rust bootstrapping

**File:** `taskfiles/dotfiles.yml`

Removed calls to `tmux:airmux:install` from both `install` and `sync` tasks.

**Benefits:**
- Cleaner separation of concerns
- Respects on-demand installation philosophy
- Reduces code duplication
- All Rust tools installed together

**Commits:**
- `ceb72b6` - refactor(rust): consolidate airmux into Rust tools installation

## Refactor 2: Make Lolcrab Optional

### Issue

The `print:done` task was failing if lolcrab (animated gradient text tool) wasn't installed, breaking the sync process.

### Solution

Added graceful fallbacks in the completion message.

**File:** `taskfiles/dotfiles.yml`

```yaml
print:done:
  desc: Prints done with a cool font and some nice gradients (animated)
  internal: true
  cmd: |
    if command -v lolcrab >/dev/null 2>&1; then
      echo DONE | figlet | lolcrab -a --speed 1 --duration 1 --gradient warm
    else
      figlet -f banner DONE || echo "✅ Sync complete!"
    fi
  silent: true
```

**Fallback chain:**
1. If lolcrab exists: Use animated gradient output
2. If figlet exists: Use banner font output
3. Otherwise: Simple emoji checkmark message

**Commits:**
- `210d415` - feat(taskfiles): make lolcrab optional with graceful fallbacks

## Cleanup 1: Remove Unused Homebrew Packages

### Issue

Brewfile contained multiple packages that were no longer used or had been replaced.

### Solution

**File:** `Brewfile`

Removed 9 unused packages:
- `iterm2` - Using WezTerm instead
- `opentofu` - Not used for Terraform
- `autojump` - Using zoxide instead
- `htop` - Using btop instead
- `tmuxinator` - Using airmux instead
- `sesh` - Using airmux instead
- `smug` - Using airmux instead
- `neofetch` - Not used
- `howdoi` - Not used

Also removed 1Password CLI tap and package (from earlier in session).

**Commits:**
- `24a3213` - chore: remove unused Homebrew packages

## Cleanup 2: Remove 1Password CLI Integration

### Issue

1Password CLI was installed and configured but no longer used.

### Solution

**Deleted:** `config/zsh/op.zsh`

Removed:
- 1Password completion setup
- SSH agent configuration
- Teleport conflict workaround

**File:** `taskfiles/darwin.yml`

Removed `op:setup` task (14 lines) that created symlinks for SSH agent compatibility.

**File:** `Brewfile`

Removed:
- `brew "1password-cli"`
- `tap "1password/tap"`

**Commits:**
- `ee3bc0d` - chore: remove 1Password CLI integration

## Cleanup 3: Other Improvements

### Banner Update

**File:** `scripts/banner.sh`

Replaced banner with cyberpunk-style "RYAN'S DOTFILES" ASCII art from the installer for consistency.

**Commits:**
- `722228d` - feat(scripts): update banner to cyberpunk ASCII art

### Hardtime.nvim Configuration

**File:** `config/nvim/lua/plugins/hardtime.lua`

```lua
restricted_keys = {
  ["h"] = { "n", "x" },
  ["l"] = { "n", "x" },
  -- Removed: ["j"] = { "n", "x" },
  -- Removed: ["k"] = { "n", "x" },
  -- ... other keys
},
```

Exempted j/k keys from hardtime restrictions to allow natural vertical navigation while keeping restrictions on horizontal movement.

**Commits:**
- `d5a7533` - feat(nvim): exempt j/k from hardtime.nvim restrictions

### Documentation Updates

**File:** `installer/README.md`

Updated to reflect current implementation:
- Removed references to deleted files (gitconfig.sh, title.txt)
- Removed 1Password SSH agent setup from darwin.sh description
- Removed unicornleap installation reference
- Removed Xcode dependency (no longer required)
- Updated Task installation notes (now via Homebrew on macOS)
- Updated Ruby installation notes (separate from bootstrap)

**Commits:**
- `2e8d5aa` - docs(installer): update README to reflect current state

### Gitignore Updates

**File:** `.gitignore`

```gitignore
# ignore Task cache and scratch file/directory
.task/
scratch
scratch/
```

Added Task's cache directory and user scratch space to gitignore.

**Commits:**
- `8be9d2c` - chore: add Task cache and scratch directory to gitignore

### Dprint Configuration

**File:** `dprint.json`

```json
"excludes": [
  // ... existing excludes
  "config/zsh/fzf-tab.zsh"
],
```

Excluded `fzf-tab.zsh` from formatting as it contains complex zsh parameter expansion syntax that shfmt cannot parse correctly. This fixed pre-push hook failures.

**Commits:**
- `4b69c4c` - fix(dprint): exclude fzf-tab.zsh from formatting

### Shell Script Formatting

**Files:**
- `installer/lib/shared.sh`
- `installer/platforms/darwin.sh`
- `installer/platforms/ubuntu.sh`

Applied dprint formatting for consistent whitespace and indentation.

**Commits:**
- `3afad19` - style(installer): format shell scripts with dprint

### Neovim Plugin Updates

**File:** `config/nvim/lazy-lock.json`

Updated Neovim plugin versions via lazy.nvim sync.

**Commits:**
- `a47f847` - chore(nvim): update plugin lockfile

## Tool Versions Philosophy

### Decision: Remove Rust from .tool-versions

Initially added Rust to `.tool-versions` to support airmux and lolcrab, but this violated the on-demand language installation philosophy.

**Solution:** Removed Rust from repository `.tool-versions` entirely via interactive rebase.

**Rationale:**
- Rust is only needed for optional tools (airmux, lolcrab)
- Users can install via `task rust:install` and `task rust:tools:install` on-demand
- Users who want Rust can add it to their global `~/.tool-versions`
- Repository `.tool-versions` should contain only essential tools (currently just `neovim nightly`)

**Implementation:**
```bash
# Dropped commit 877076d from history
GIT_SEQUENCE_EDITOR='sed -i "" "s/^pick 877076d/drop 877076d/"' git rebase -i 877076d^
git push --force-with-lease
```

## Final State

### Commits Created

All changes documented in **16 granular conventional commits**:

```
4b69c4c fix(dprint): exclude fzf-tab.zsh from formatting
3cd6700 refactor(rust): consolidate airmux into Rust tools installation
a62e8a1 chore: add Task cache and scratch directory to gitignore
13c3c5f fix(rust): use Homebrew for cargo-watch on macOS
3afad19 style(installer): format shell scripts with dprint
2e8d5aa docs(installer): update README to reflect current state
210d415 feat(taskfiles): make lolcrab optional with graceful fallbacks
1d6c29d fix(taskfiles): update to modern asdf command syntax
722228d feat(scripts): update banner to cyberpunk ASCII art
d7eded0 feat(wezterm): make window decorations platform-specific
417c12f fix(tmux): fix Ctrl+S prefix and zsh shell issues
d5a7533 feat(nvim): exempt j/k from hardtime.nvim restrictions
a47f847 chore(nvim): update plugin lockfile
24a3213 chore: remove unused Homebrew packages
ee3bc0d chore: remove 1Password CLI integration
86c05bc chore(brew): update packages
```

### Verification Steps

1. **Tmux prefix:** `Ctrl+S` followed by `s` splits pane vertically ✅
2. **New tmux panes:** Launch zsh with powerline prompt ✅
3. **WezTerm UI:** No window button overlap on macOS ✅
4. **Rust tools:** All installed and accessible via `asdf reshim rust` ✅
5. **asdf commands:** Modern syntax throughout ✅
6. **Optional tools:** Lolcrab and airmux installed via Rust tasks ✅
7. **CI checks:** All pre-push hooks passing ✅

## Lessons Learned

1. **Terminal flow control:** Always check `stty` settings when Ctrl+S/Ctrl+Q don't work as expected
2. **Tmux plugins:** Can override configuration - set values after plugin initialization when needed
3. **Shell substitution timing:** Avoid `run-shell` with `$(command)` in tmux - use direct values
4. **Platform-specific builds:** Some cargo packages have macOS-specific issues - Homebrew precompiled binaries can be a workaround
5. **asdf versioning:** Keep up with breaking changes in version managers - deprecated commands removed
6. **On-demand philosophy:** Language runtimes should be optional unless absolutely required
7. **Interactive rebase:** Can cleanly remove commits from history when needed
8. **Conventional commits:** Granular, well-documented commits make history much more useful

## References

- Unified keybind architecture: README.md "Unified Window/Pane Management" section
- Flow control discussion: 2025-11-22-zsh-stty-ctrl-z-fixes.md
- asdf deprecations: https://asdf-vm.com/manage/core.html
- cargo-watch issue: https://github.com/watchexec/cargo-watch/issues/
