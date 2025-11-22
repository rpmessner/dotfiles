# Tmux Leader Key Change and Ctrl+Z Footgun Prevention

**Date:** 2025-11-22
**Status:** Complete
**Related:** ROADMAP.md (Section 5.1)

## Summary

Changed tmux prefix/leader from `Ctrl+Z` to `Ctrl+S` and cleared the way for any conflicting keybinds to prevent footguns, particularly the issue where Ctrl+Z would suspend Claude Code sessions in neovim terminal windows.

## Problem Statement

Previously, tmux used `Ctrl+Z` as the prefix key. This created several issues:

1. **Accidental suspends in neovim terminal mode** - Pressing Ctrl+Z in a neovim terminal window (e.g., Claude Code session) would suspend the process, making it unrecoverable
2. **Conflict with shell suspend** - Ctrl+Z is the traditional Unix suspend signal (SIGTSTP)
3. **Poor ergonomics** - Ctrl+Z is awkward to press and conflicts with muscle memory

The new tmux prefix `Ctrl+S` needed:
- Terminal flow control disabled (Ctrl+S/Ctrl+Q can freeze terminals)
- Protection against accidental Ctrl+Z in terminal contexts
- Safe alternative for intentional process suspension

## Solution

### 1. Changed tmux Leader Key

**File:** `config/tmux/tmux.conf`

```tmux
# setup leader key
  unbind C-b
  set -g prefix C-s
  bind C-s send-prefix
```

**Key decision:** Removed `unbind C-z` to keep config clean from transition state code. Config should reflect desired end state for fresh sessions, not migration paths.

### 2. Disabled Ctrl+Z in Neovim Terminal Mode

**File:** `config/nvim/lua/config/keymaps.lua`

```lua
-- prevent ctrl+z from suspending processes in terminal mode
tmap({ "<C-z>", "<nop>", { desc = "Disabled (use exit or <C-d> instead)" } })
```

This prevents accidental suspends when working in neovim terminal buffers (critical for Claude Code, language servers, test runners, etc.).

### 3. Disabled Terminal Flow Control

**File:** `config/zsh/settings.zsh`

```zsh
# Disable terminal flow control (Ctrl+S/Ctrl+Q) to allow Ctrl+S as tmux prefix
stty -ixon
```

Without this, pressing Ctrl+S would freeze the terminal (legacy flow control). The `stty -ixon` command disables this behavior.

### 4. Added Safe Suspend Binding in WezTerm

**File:** `config/wezterm/wezterm.lua`

```lua
-- Suspend process (safer alternative to bare Ctrl+Z)
{
  key = 'z',
  mods = 'LEADER',
  action = wezterm.action.SendKey { key = 'z', mods = 'CTRL' },
}
```

Provides intentional suspend via `Ctrl+Space z` - requires deliberate action, preventing accidental suspends.

## Key Bindings Reference

### tmux
- **Prefix/Leader:** `Ctrl+S` (was `Ctrl+Z`)
- **Create window:** `Ctrl+S c`
- **Split vertical:** `Ctrl+S %`
- **Split horizontal:** `Ctrl+S "`
- **Zoom pane:** `Ctrl+S z`

### WezTerm
- **Leader:** `Ctrl+Space` (unchanged)
- **Suspend process:** `Ctrl+Space z` (new safe alternative)

### Neovim Terminal Mode
- **Ctrl+Z:** Disabled (mapped to `<nop>`)
- **Exit terminal:** `<Esc><Esc>` or `Ctrl+O`

## Design Philosophy

**Clean config principle:** Configuration files should represent the desired end state for fresh installations, not temporary transition states. The decision to remove `unbind C-z` reflects this - on a fresh tmux session, only `C-b` (the built-in default) needs unbinding. Including transition code like `unbind C-z` would only be relevant during config reloads, which is a temporary state.

**Footgun prevention:** Rather than relying on muscle memory retraining, we disabled the dangerous behavior (Ctrl+Z in terminal mode) and provided a safe alternative (Leader+z in WezTerm) that requires deliberate action.

## Testing Results

All changes tested and working:
- ✅ Tmux responds to Ctrl+S prefix
- ✅ Ctrl+Z in neovim terminal mode is disabled
- ✅ Ctrl+S doesn't freeze terminal
- ✅ WezTerm Leader+z suspends processes as expected
- ✅ No conflicts with other keybindings

## Files Modified

1. `config/tmux/tmux.conf` - Changed prefix to Ctrl+S
2. `config/nvim/lua/config/keymaps.lua` - Disabled Ctrl+Z in terminal mode
3. `config/zsh/settings.zsh` - Disabled flow control with stty
4. `config/wezterm/wezterm.lua` - Added Leader+z suspend binding

## Follow-up: Dual Prefix Approach (2025-11-22 continued)

After initial implementation, the Neovim terminal mode mapping proved insufficient to prevent accidental Ctrl+Z suspends. The solution was to make Ctrl+Z a tmux prefix key alongside Ctrl+S.

**Additional Changes:**

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

Removed the `bind C-z last-window` binding since Ctrl+Z is now a prefix.

**Benefits:**
- Ctrl+Z in any tmux pane is intercepted by tmux (waits for second key)
- No process suspends can occur accidentally in tmux
- Ctrl+S remains the primary, ergonomic prefix
- Ctrl+Z still works in non-tmux sessions (acceptable trade-off)

**Platform Support:**
- Added `xdg-utils` to `taskfiles/ubuntu.yml` for WSL/Linux support (required by tmux plugins)

## Related Work

- ROADMAP.md Section 5.1 - Tmux Leader Change (marked complete)
- Previous session: 2025-11-21-wezterm-wsl-cross-platform-fixes.md (WezTerm leader key setup)
- Follow-up session: 2025-11-22-zsh-stty-ctrl-z-fixes.md (stty TTY check and final Ctrl+Z solution)
