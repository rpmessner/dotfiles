# WSL2 Clipboard Paste Fix Session

**Date**: November 23, 2025 (Evening)
**Platform**: Windows 11 + WSL2 (Ubuntu 24.04)
**Focus**: Fix broken paste functionality (Windows → tmux)
**Status**: ✅ Complete

---

## Overview

Fixed clipboard paste issue where `Ctrl+Shift+V` in WezTerm was clearing the Windows clipboard instead of pasting into tmux. The root cause was tmux's OSC 52 clipboard synchronization feature interfering with WezTerm's native paste mechanism.

---

## Problem Statement

### Initial State (Regression from Previous Session)
- ✅ Copy from tmux to Windows worked (using `clip.exe`)
- ❌ Paste from Windows to tmux cleared the Windows clipboard
- ✅ Paste worked in naked WezTerm (outside tmux)
- ❌ Paste failed inside tmux panes

### User Report
"Paste was working at the end of last session, but now it's broken. When I try to paste with `Ctrl+Shift+V` in tmux, it clears my Windows clipboard."

---

## Root Cause Analysis

### Investigation Steps
1. Verified `set-clipboard` was correctly set to `off` on WSL2 ✓
2. Confirmed `clip.exe` path and copy functionality working ✓
3. Tested paste in naked WezTerm - **worked** ✓
4. Tested paste in tmux - **failed and cleared clipboard** ✗

### The Culprit: OSC 52 Clipboard Synchronization
```bash
# Command revealed the issue:
tmux show-options -s | grep terminal-features
# Output: terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title
```

The `clipboard` terminal feature enables OSC 52 escape sequences, which allow terminals to read/write the system clipboard. When WezTerm pasted into tmux:

1. WezTerm sent paste data to tmux (as bracketed paste)
2. tmux received the paste
3. tmux tried to "sync" it back to the terminal clipboard via OSC 52
4. This OSC 52 sequence cleared the Windows clipboard

**Why it broke**: The `set-clipboard off` setting only disables tmux's *automatic* clipboard syncing. It doesn't disable the terminal's OSC 52 *capability*, which tmux still tried to use.

---

## Solution Implemented

### Fix: Disable OSC 52 Terminal Feature on WSL2

**File**: `config/tmux/tmux.conf` (line 221)

Added `terminal-features` override to disable clipboard capability:

```tmux
if-shell "uname -r | grep -i microsoft" \
  "set -s set-clipboard off; \
   set -as terminal-features 'xterm*:clipboard@'; \
   ..."
```

The `@` suffix in `clipboard@` explicitly disables that terminal feature.

### Complete Clipboard Configuration

```tmux
# Platform-specific clipboard integration
# WSL2: Disable OSC 52 clipboard sync to prevent clearing Windows clipboard on paste
#       Use clip.exe for copy only, WezTerm handles paste natively
# macOS: Keep default clipboard behavior
if-shell "uname -r | grep -i microsoft" \
  "set -s set-clipboard off; \
   set -as terminal-features 'xterm*:clipboard@'; \
   bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'clip.exe'; \
   bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'clip.exe'; \
   bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'clip.exe'" \
  "bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'; \
   bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'; \
   bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'"
```

**Key Points**:
- **WSL2**: Disables both `set-clipboard` and OSC 52 terminal feature
- **macOS**: No changes (keeps working as before)
- **Copy**: Uses platform-specific tools (`clip.exe` on WSL2, `pbcopy` on macOS)
- **Paste**: Handled entirely by WezTerm, no tmux involvement

---

## Testing Results

### ✅ New tmux Sessions
- Copy from tmux → Windows: **Works** (`y`, `Enter`, mouse drag)
- Paste from Windows → tmux: **Works** (`Ctrl+Shift+V`)
- Clipboard preservation: **Windows clipboard NOT cleared**

### ⚠️ Existing tmux Sessions
- Fix requires new tmux session or server restart
- User chose to handle existing sessions manually

---

## Files Modified

### Configuration Files

1. **config/tmux/tmux.conf** (2 changes)
   - Lines 14-16: Cross-platform shell detection (unchanged from previous session)
   - Lines 215-227: **NEW** - OSC 52 clipboard feature disabled on WSL2

2. **config/wezterm/wezterm.lua** (2 changes)
   - Lines 242-244: Keyboard protocol compatibility settings
   - Lines 256-284: Explicit copy/paste keybindings + `Shift+Insert` alternative

### Documentation Files

3. **docs/sessions/2025-11-23-wsl2-clipboard-paste-fix.md** (this file)

---

## Additional Cleanup Done

### Invalid WezTerm Config Fields Removed
During troubleshooting, discovered and removed invalid config options:
- `config.paste_speed = 0` (not a valid WezTerm field)
- `config.enable_bracketed_paste = true` (not a valid WezTerm field)

These were causing config reload errors.

---

## Technical Deep Dive

### The Copy Flow (Working)
```
tmux copy mode (y/Enter/mouse)
  → send-keys -X copy-pipe-and-cancel 'clip.exe'
  → clip.exe writes to Windows clipboard
  → Available to all Windows apps
```

### The Paste Flow (Fixed)
```
Windows app (Ctrl+C)
  → Windows clipboard
  → WezTerm (Ctrl+Shift+V)
  → WezTerm reads Windows clipboard
  → WezTerm sends bracketed paste to WSL2 terminal
  → tmux receives paste (OSC 52 disabled, no sync-back)
  → Text appears in shell
  → Windows clipboard PRESERVED
```

### Why OSC 52 Was Problematic
OSC 52 is an escape sequence that allows terminal applications to read/write the system clipboard:
- **Write**: `\e]52;c;<base64-data>\e\\` - puts data in clipboard
- **Read**: `\e]52;c;?\e\\` - requests clipboard content

When enabled, tmux tried to use OSC 52 to sync pasted content back to the "terminal clipboard", which on WSL2 meant the Windows clipboard, effectively clearing it.

---

## Lessons Learned

1. **set-clipboard vs terminal-features**: Two separate mechanisms
   - `set-clipboard off` disables *automatic* syncing
   - `terminal-features clipboard@` disables the *capability* entirely

2. **Platform Detection**: Must be comprehensive
   - Not just shell paths, but clipboard behaviors differ significantly
   - WSL2 clipboard is Windows clipboard (via `/mnt/c/` paths)
   - macOS clipboard is separate (via `pbcopy`/`pbpaste`)

3. **Test in Clean Sessions**: Config changes to server options require:
   - New tmux session (`tmux new`)
   - OR manual `tmux set` commands
   - OR full server restart (`tmux kill-server`)

4. **WezTerm Handles Paste**: On WSL2, paste should go:
   - Windows clipboard → WezTerm → WSL2 terminal
   - NOT: Windows clipboard → tmux → back to clipboard

---

## Related Sessions

- **Previous Session**: `docs/sessions/2025-11-23-wsl2-clipboard-integration.md`
  - Initial clipboard implementation (copy was working)
  - Paste was reported working at end of session
  - Likely broken during cleanup/documentation phase

- **WSL2 Setup**: `docs/sessions/2025-11-20-wsl2-ubuntu-installation.md`
- **WezTerm Cross-Platform**: `docs/sessions/2025-11-21-wezterm-wsl-cross-platform-fixes.md`

---

## Future Considerations

### Potential Improvements
1. **Alternative Clipboard Tool**: Install `win32yank`
   - Purpose-built for WSL2 clipboard operations
   - Potentially faster than `clip.exe`
   - Bidirectional (can read AND write clipboard)

2. **Mouse Middle-Click Paste**: Add binding for traditional Unix paste
   - Would use tmux buffer, not Windows clipboard
   - Complementary to `Ctrl+Shift+V`

3. **Session Migration Script**: Automated way to apply settings to existing sessions
   - Detect running tmux sessions
   - Apply `terminal-features` changes
   - Reload keybindings

---

## Commands Reference

### Copy from tmux → Windows
```bash
# Enter copy mode
Ctrl+S then [

# Navigate and select
hjkl          # Navigate
v             # Start visual selection
y             # Yank (copy) and exit
Enter         # Alternative copy and exit
Mouse drag    # Select with mouse
```

### Paste from Windows → tmux
```bash
# Primary method
Ctrl+Shift+V  # Paste in WezTerm (works in tmux)

# Alternative
Shift+Insert  # Also pastes (added as fallback)
```

### Verify Fix
```bash
# Check terminal features (should show clipboard@ on WSL2)
tmux show-options -s terminal-features

# Check set-clipboard (should be "off" on WSL2)
tmux show-options -s set-clipboard

# Test copy
echo "test" | clip.exe

# Test if new sessions work
tmux new -s test
# Try Ctrl+Shift+V
```

---

## Success Criteria - All Met ✅

- [x] Copy from tmux to Windows clipboard works
- [x] Paste from Windows to tmux works in new sessions
- [x] Windows clipboard is NOT cleared on paste
- [x] Works in both naked shell and tmux panes
- [x] Cross-platform compatible (macOS unchanged, WSL2 fixed)
- [x] No conflicts with existing keybindings
- [x] Fully documented
- [x] Root cause identified and explained

---

## Post-Session Follow-Up

### Issue: Fix Not Persisting Across Config Reloads

**Problem Discovered**: After initial fix, paste worked in new sessions but broke again after `tmux source-file`.

**Root Cause**: Using `set -as terminal-features 'xterm*:clipboard@'` (append) didn't actually remove clipboard from the auto-detected `terminal-features[0]`:
```
terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title  ← enabled
terminal-features[3] xterm*:clipboard@  ← disable attempt, ignored
```

**Final Fix**: Replace `terminal-features[0]` entirely instead of appending:
```tmux
set -s terminal-features[0] 'xterm*:ccolour:cstyle:focus:title'
```

This removes `clipboard` from the feature list while preserving other capabilities (colors, cursor, focus, title).

**Commit**: `fix(tmux): replace terminal-features instead of appending` (f187994)

---

**Status**: ✅ Production Ready (persists across config reloads)
**Date Completed**: November 23, 2025
**Next Session**: WSL2 Performance Optimization (shell startup, git, .wslconfig)
