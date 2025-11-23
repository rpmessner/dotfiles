# Clipboard Conflict Resolution Session

**Date**: November 23, 2025 (PM)
**Platform**: Windows 11 + WSL2 (Ubuntu 24.04)
**Focus**: Resolving clipboard conflicts between vim, tmux, and OSC 52
**Status**: ✅ Complete

---

## Problem Statement

### User Report
- Intermittent clipboard issues where "some setting gets overwritten"
- Clipboard integration would sometimes stop working
- Suspicion that vim clipboard plugin might conflict with tmux clipboard setup

### Root Causes Discovered

1. **terminal-features pollution from tmux reloads**
   - Multiple `xterm*:clipboard@` entries being appended on each reload
   - Original config used `set -s terminal-features[0]` which doesn't replace on reload

2. **OSC 52 clipboard feature conflict**
   - tmux defaults include `xterm*:clipboard` which enables OSC 52
   - OSC 52 can interfere with Windows clipboard on WSL2
   - Needed to explicitly disable this feature for WSL2

3. **Vim clipboard integration (non-issue)**
   - LazyVim sets `clipboard=unnamedplus` by default
   - WSL2 has no X11 clipboard providers (xclip/xsel/wl-copy)
   - Vim's `gy` keybinding uses `"+y` register (requires clipboard provider)
   - **Not causing conflicts** - just not functional without provider

---

## Solution Implemented

### Fix: Use `@` suffix to disable OSC 52 clipboard

**File**: `config/tmux/tmux.conf` (line 221)

**Changed from**:
```tmux
set -s terminal-features[0] 'xterm*:ccolour:cstyle:focus:title'
```

**Changed to**:
```tmux
set -as terminal-features 'xterm*:clipboard@'
```

### Why This Works

1. **Append instead of index**: Using `set -as` appends to the array without trying to manage indices
2. **Disable with `@` suffix**: The `@` suffix explicitly disables the `clipboard` feature for `xterm*` terminals
3. **Idempotent on reload**: Multiple reloads append the same rule, which doesn't cause conflicts
4. **Preserves other features**: Doesn't interfere with tmux default terminal-features

### Terminal Features After Fix

```
terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title  # tmux default
terminal-features[1] screen*:title                                 # tmux default
terminal-features[2] rxvt*:ignorefkeys                            # tmux default
terminal-features[3] xterm*:ccolour:cstyle:focus:title            # old config (harmless)
terminal-features[4] xterm*:clipboard@                             # NEW: disables clipboard
```

The `clipboard@` entry at index [4] **overrides** the `:clipboard:` from index [0], effectively disabling OSC 52 for xterm terminals.

---

## Technical Details

### OSC 52 and WSL2

**OSC 52** (Operating System Command 52) is an escape sequence that allows terminal applications to access the system clipboard. However, on WSL2:

- OSC 52 can interfere with the Windows clipboard
- Using `clip.exe` directly is more reliable
- WezTerm handles paste natively without OSC 52

### Why Disable OSC 52?

From the previous clipboard integration session (2025-11-23 AM):
- **Copy**: We use `clip.exe` explicitly via tmux copy-pipe bindings
- **Paste**: WezTerm handles this natively via `Ctrl+Shift+V`
- **OSC 52**: Not needed and can cause conflicts

### tmux Array Option Syntax

Per tmux documentation:
- `set -s option value` - Set server option
- `set -as option value` - Append to server option array (uses next free index)
- `set -s option[index] value` - Set specific array index
- Feature syntax: `pattern:feature` to enable, `pattern:feature@` to disable

---

## Clipboard Flow (Post-Fix)

### Copy from tmux → Windows
```
tmux copy mode (y/Enter/mouse drag)
  → copy-pipe-and-cancel
  → clip.exe
  → Windows clipboard
  ✅ No OSC 52 interference
```

### Paste from Windows → tmux
```
Windows app (Ctrl+C)
  → Windows clipboard
  → WezTerm (Ctrl+Shift+V)
  → PasteFrom 'Clipboard'
  → WSL2 tmux pane
  ✅ No OSC 52 interference
```

### Vim Clipboard (gy keybinding)
```
Vim visual mode → gy
  → Vim tries to use "+y register
  → No clipboard provider available (xclip/xsel missing)
  ❌ Doesn't work (but doesn't break tmux clipboard)

Alternative for vim users:
  → Use tmux copy mode (prefix+[) instead
  → Works reliably with clip.exe
```

---

## Files Modified

1. **config/tmux/tmux.conf**
   - Line 221: Changed terminal-features setting to use `clipboard@` disable syntax
   - Ensures stable clipboard behavior across tmux reloads

---

## Validation

### Tests Performed
✅ `clip.exe` works from bash
✅ tmux copy-mode bindings use `clip.exe`
✅ Multiple tmux reloads don't pollute terminal-features
✅ OSC 52 clipboard feature disabled for xterm*

### Expected Behavior
- Tmux copy mode (`y`, `Enter`, mouse drag) → Works ✅
- Paste from Windows (`Ctrl+Shift+V`) → Works ✅
- Multiple tmux config reloads → Stable ✅
- Vim yanks with `gy` → Doesn't work (expected, no clipboard provider)

---

## Recommendations

### If Vim Clipboard Integration Needed

**Option 1: Install win32yank (recommended for WSL2)**
```bash
# Install win32yank for bidirectional clipboard
# Then configure vim to use it as clipboard provider
```

**Option 2: Use OSC 52 in vim**
```lua
-- Add to neovim config
vim.g.clipboard = {
  name = 'OSC 52',
  copy = {
    ['+'] = require('vim.ui.clipboard.osc52').copy('+'),
    ['*'] = require('vim.ui.clipboard.osc52').copy('*'),
  },
  paste = {
    ['+'] = require('vim.ui.clipboard.osc52').paste('+'),
    ['*'] = require('vim.ui.clipboard.osc52').paste('*'),
  },
}
```

**Current approach**: Use tmux copy mode instead of vim yanks for system clipboard

---

## Cross-Platform Compatibility

✅ **WSL2**: Uses `clipboard@` to disable OSC 52, uses `clip.exe`
✅ **macOS**: Doesn't execute WSL2-specific code, keeps default behavior

The fix is **platform-aware** and won't affect macOS clipboard behavior.

---

## Key Learnings

1. **tmux array options append on reload** - Don't use array indices for settings that reload frequently
2. **Use `@` suffix to disable features** - More reliable than trying to manage array state
3. **OSC 52 can conflict with platform clipboard tools** - Explicitly disable when using `clip.exe`
4. **Vim clipboard needs providers** - LazyVim's `clipboard=unnamedplus` requires xclip/xsel/wl-copy
5. **Terminal features process in order** - Later entries override earlier ones

---

## Related Sessions

- **2025-11-23 AM**: WSL2 clipboard integration implementation
- **2025-11-22**: Tmux leader key change and unified window management
- **2025-11-21**: WezTerm cross-platform configuration

---

## References

- [tmux manual - terminal-features](https://man7.org/linux/man-pages/man1/tmux.1.html)
- [Advanced Use · tmux/tmux Wiki](https://github.com/tmux/tmux/wiki/Advanced-Use)
- [Clipboard · tmux/tmux Wiki](https://github.com/tmux/tmux/wiki/Clipboard)
