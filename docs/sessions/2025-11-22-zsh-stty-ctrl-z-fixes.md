# Zsh stty Fix and Tmux Ctrl+Z Prevention

**Date:** 2025-11-22
**Status:** Complete
**Related:** 2025-11-22-tmux-leader-key-change.md

## Summary

Fixed two issues encountered during the tmux leader key migration:
1. Zsh initialization errors from `stty` command in non-TTY contexts
2. Ctrl+Z still suspending processes in tmux panes despite Neovim mapping

## Problem 1: Zsh Initialization Errors

### Issue

When spawning zsh in non-interactive contexts (e.g., Claude Code shell sessions), the following errors appeared:

```
stty: 'standard input': Inappropriate ioctl for device
```

This output interfered with Powerlevel10k's instant prompt feature, causing warnings about console output during initialization.

### Root Cause

`config/zsh/settings.zsh` was unconditionally running `stty -ixon` to disable terminal flow control (needed for Ctrl+S as tmux prefix). The `stty` command requires a TTY, and fails when stdin is not a terminal.

### Solution

**File:** `config/zsh/settings.zsh`

```zsh
# Disable terminal flow control (Ctrl+S/Ctrl+Q) to allow Ctrl+S as tmux prefix
# Only run stty if stdin is a TTY
if [[ -t 0 ]]; then
  stty -ixon
fi
```

The `[[ -t 0 ]]` test checks if file descriptor 0 (stdin) is a TTY before running `stty`.

**Benefits:**
- No errors in non-interactive shell contexts
- Powerlevel10k instant prompt works cleanly
- Terminal flow control still disabled when needed
- Same functionality, better compatibility

## Problem 2: Ctrl+Z Suspending Processes in Tmux

### Issue

Despite adding a Neovim terminal mode mapping to disable Ctrl+Z:
```lua
tmap({ "<C-z>", "<nop>", { desc = "Disabled (use exit or <C-d> instead)" } })
```

Pressing Ctrl+Z in tmux panes was still suspending processes (Claude Code, test runners, etc.).

### Root Cause

The Neovim mapping only applies inside Neovim's terminal mode. When running processes directly in tmux panes (outside Neovim), Ctrl+Z sends SIGTSTP normally.

### Solution: Dual Prefix Approach

Make Ctrl+Z a secondary tmux prefix key alongside Ctrl+S. This intercepts Ctrl+Z at the tmux level before it can suspend any process.

**File:** `config/tmux/tmux.conf`

```tmux
# setup leader keys
# C-s is primary (ergonomic), C-z is secondary (prevents accidental suspend)
  unbind C-b
  set -g prefix C-s
  set -g prefix2 C-z
  bind C-s send-prefix
  bind C-z send-prefix -2
```

Also removed the conflicting binding:
```tmux
# Removed: bind C-z last-window
# Now just: bind Tab last-window
```

**How It Works:**
- Ctrl+Z is intercepted by tmux
- Tmux waits for a second key (prefix behavior)
- No SIGTSTP is sent to the underlying process
- Ctrl+S remains the primary, intentional prefix
- Tab takes over the "last window" functionality

**Design Philosophy:**

Rather than trying to retrain muscle memory or remember when Ctrl+Z is safe, we made it always safe in tmux by intercepting it. This is more robust than relying on application-level mappings (Neovim, WezTerm) which have limited scope.

**Acceptable Trade-offs:**
- Ctrl+Z still works as suspend in non-tmux sessions (expected behavior)
- Lost the convenient `C-z C-z` window toggle (Tab is equivalent)
- Gained safety: impossible to accidentally suspend processes in tmux

## Problem 3: Missing xdg-utils on WSL

### Issue

When reloading tmux configuration on WSL/Ubuntu, received error:
```
Error: ensure xdg-open is installed
```

### Root Cause

Some tmux plugins (likely `tmux-yank` or `extrakto`) depend on `xdg-open` for opening URLs/files. On macOS, the `open` command is built-in. On Linux, the `xdg-utils` package provides `xdg-open`.

### Solution

**File:** `taskfiles/ubuntu.yml`

Added `xdg-utils` to the Ubuntu package list:
```yaml
sudo apt install -y \
  # ... other packages ...
  wx-common \
  xdg-utils \
  xsltproc \
  # ... more packages ...
```

**Benefits:**
- Future Ubuntu/WSL installations automatically include `xdg-utils`
- Tmux plugins work correctly out of the box
- Consistent with cross-platform support goals

## Enhancement: Smart Pane Navigation

### Context

While testing the new tmux prefix keys, identified an opportunity to improve pane navigation UX. When navigating between panes in complex layouts (e.g., vertical split with horizontal sub-splits), tmux's default behavior can be unpredictable about which pane gets selected.

### Example Layout
```
┌─────┬─────┐
│     │  1  │ ← Want to always land here when pressing prefix+l from left
│  L  ├─────┤
│     │  2  │
└─────┴─────┘
```

### Solution

Created a smart pane selection script that prefers topmost/leftmost panes when navigating.

**File:** `scripts/tmux-smart-select-pane.sh`

The script:
- **Right navigation (l):** Selects the topmost pane to the right
- **Left navigation (h):** Selects the topmost pane to the left
- **Down navigation (j):** Selects the leftmost pane below
- **Up navigation (k):** Selects the leftmost pane above
- Falls back to tmux default if no pane exists in that direction

**Algorithm:**
1. Get current pane boundaries (left, right, top, bottom coordinates)
2. Find all panes in the desired direction
3. Sort by secondary axis (vertical pos for horizontal nav, horizontal pos for vertical nav)
4. Select the first (top/leftmost) pane

**File:** `config/tmux/tmux.conf`

Updated pane navigation bindings:
```tmux
# smart pane switching (prefers topmost/leftmost panes)
  bind h run-shell "~/.dotfiles/scripts/tmux-smart-select-pane.sh L"
  bind j run-shell "~/.dotfiles/scripts/tmux-smart-select-pane.sh D"
  bind k run-shell "~/.dotfiles/scripts/tmux-smart-select-pane.sh U"
  bind l run-shell "~/.dotfiles/scripts/tmux-smart-select-pane.sh R"
```

**Benefits:**
- Predictable navigation in complex pane layouts
- Always jumps to the "primary" pane (top/left) when multiple options exist
- Maintains muscle memory (still uses h/j/k/l)
- Consistent behavior across all four directions

## Enhancement: Vim-like Split Bindings

### Context

After implementing the new tmux prefix and smart navigation, identified an opportunity to unify split keybindings across vim, tmux, and WezTerm for consistent muscle memory.

### Problem

Different tools used different split bindings:
- Vim: `C-w s` (horizontal), `C-w v` (vertical)
- tmux: `Leader -` (horizontal), `Leader \` (vertical)
- WezTerm: `Leader Shift+"` (horizontal), `Leader Shift+%` (vertical)

This inconsistency makes it harder to develop muscle memory across environments.

### Solution

Unified split bindings to match vim's convention:
- `Leader s` → horizontal split (matches vim `C-w s`)
- `Leader v` → vertical split (matches vim `C-w v`)

**File:** `config/tmux/tmux.conf`
- Replaced `Leader -` and `Leader \` with `Leader s` and `Leader v`
- Moved fuzzy session finder from `Leader s` to `Leader Shift+S`
- Kept default bindings (`Leader "` and `Leader %`) as passive fallbacks

**File:** `config/wezterm/wezterm.lua`
- Added `Leader s` and `Leader v` bindings
- Kept `Leader Shift+"` and `Leader Shift+%` as alternatives

**Rationale:** Creating consistent bindings across all environments reduces cognitive load and makes switching between vim, tmux, and WezTerm seamless.

## Files Modified

1. `config/zsh/settings.zsh` - Added TTY check for stty command
2. `config/tmux/tmux.conf` - Added Ctrl+Z as secondary prefix, smart pane navigation, vim-like split bindings
3. `config/wezterm/wezterm.lua` - Added vim-like split bindings
4. `taskfiles/ubuntu.yml` - Added xdg-utils package
5. `scripts/tmux-smart-select-pane.sh` - New script for intelligent pane selection
6. `.airmux.yml` - Renamed editor window to dots
7. `CLAUDE.md` - Updated key bindings documentation
8. `docs/sessions/2025-11-22-tmux-leader-key-change.md` - Added follow-up section

## Testing Results

All changes tested and working:
- ✅ No stty errors when spawning zsh in non-TTY contexts
- ✅ Powerlevel10k instant prompt works cleanly
- ✅ Ctrl+Z in tmux panes cannot suspend processes
- ✅ Ctrl+S prefix works as expected
- ✅ Tab switches between windows
- ✅ Ctrl+Z still works in non-tmux sessions
- ✅ Smart pane navigation selects topmost/leftmost panes predictably
- ✅ Vim-like split bindings (Leader s/v) work in both tmux and WezTerm
- ✅ Fuzzy session finder accessible via Leader Shift+S

## Key Decisions

**Keep Neovim Ctrl+Z mapping:** Even though tmux now intercepts Ctrl+Z, we kept the Neovim terminal mode mapping as belt-and-suspenders protection when running Neovim outside tmux.

**Dual prefix over unbind:** Rather than completely unbinding Ctrl+Z (which would make it pass through to processes), making it a prefix key intercepts it safely while maintaining tmux's composability.

**Platform-specific packages:** Added xdg-utils to Ubuntu-specific package list rather than cross-platform, since macOS has `open` built-in.

**Smart pane navigation over default:** Rather than using tmux's default directional selection which can be unpredictable in complex layouts, we implemented a script that consistently prefers topmost/leftmost panes. This makes navigation more predictable and reduces cognitive load.

**Vim-like splits over traditional:** Changed split bindings to match vim's convention (`Leader s`/`Leader v` instead of `Leader -`/`Leader \`) for consistency across environments. Kept tmux defaults (`Leader "`/`Leader %`) as passive fallbacks rather than unbinding them—they don't cause confusion since they're just available, not actively competing.

## Lessons Learned

1. **TTY assumptions:** Always check if stdin/stdout is a TTY before running commands like `stty`, `tput`, or other terminal-specific utilities
2. **Scope of protection:** Application-level keybindings (Neovim, WezTerm) only protect within that application's scope. Tmux-level interception provides universal protection across all panes
3. **Secondary prefix pattern:** Tmux's `prefix2` feature is perfect for intercepting dangerous keybindings while maintaining a primary ergonomic prefix
4. **Cross-platform testing:** Testing on WSL revealed the missing `xdg-utils` dependency that wouldn't appear on macOS
5. **UX improvements from dogfooding:** Testing the new tmux prefix keys revealed navigation inconsistencies in complex pane layouts, leading to the smart pane selection enhancement
6. **Unified keybindings reduce cognitive load:** Matching split bindings across vim, tmux, and WezTerm creates seamless muscle memory across environments. The small effort to unify pays dividends in daily use

## Related Sessions

- 2025-11-22-tmux-leader-key-change.md - Initial tmux leader migration
- 2025-11-21-wezterm-wsl-cross-platform-fixes.md - WezTerm leader key setup
- Future: Full cross-platform compatibility testing

## Commands Reference

### Reload tmux config
```bash
# In tmux, press: Ctrl+S r (or Ctrl+Z r)
# Or from command line:
tmux source-file ~/.config/tmux/tmux.conf
```

### Test TTY status
```bash
# Returns true if stdin is a TTY
[[ -t 0 ]] && echo "stdin is a TTY"

# Returns true if stdout is a TTY
[[ -t 1 ]] && echo "stdout is a TTY"
```

### Install xdg-utils manually
```bash
sudo apt-get install -y xdg-utils
```
