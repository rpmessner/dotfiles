# WSL2 Clipboard Integration Session

**Date**: November 23, 2025
**Platform**: Windows 11 + WSL2 (Ubuntu 24.04)
**Focus**: Bidirectional clipboard integration between Windows and tmux/WezTerm
**Status**: ✅ Complete

---

## Overview

Implemented fast, bidirectional clipboard integration for WSL2 development environment. Clipboard now works seamlessly between Windows applications and tmux panes running in WSL2.

---

## Problem Statement

### Initial State
- ✅ Copy from tmux to Windows worked (using `clip.exe`)
- ❌ Paste from Windows to tmux didn't work
- ❌ When paste did work, it was extremely slow
- ❌ Cross-platform shell path hardcoded to macOS

### User Requirements
- Bidirectional clipboard (Windows ↔ tmux)
- Fast paste operations (no lag)
- Work within tmux sessions
- Cross-platform compatibility (macOS + WSL2)

---

## Solution Implemented

### 1. Fixed Cross-Platform Shell Detection
**File**: `config/tmux/tmux.conf` (lines 14-16)

**Problem**: Hardcoded `/opt/homebrew/bin/zsh` (macOS path) caused tmux to fail on WSL2

**Solution**: Auto-detect zsh path based on platform
```tmux
if-shell "test -f /opt/homebrew/bin/zsh" \
  "set-option -g default-shell /opt/homebrew/bin/zsh" \
  "set-option -g default-shell /usr/bin/zsh"
```

### 2. Platform-Specific Clipboard Integration
**File**: `config/tmux/tmux.conf` (lines 212-220)

**Solution**: Detect WSL2 and use appropriate clipboard tool
```tmux
# Platform-specific clipboard integration
# WSL2: Use clip.exe to copy to Windows clipboard
if-shell "uname -r | grep -i microsoft" \
  "bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'clip.exe'; \
   bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'clip.exe'; \
   bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'clip.exe'" \
  "bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'; \
   bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'; \
   bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'reattach-to-user-namespace pbcopy'"
```

**Features**:
- Detects WSL2 via `uname -r | grep -i microsoft`
- Uses `clip.exe` on WSL2, `pbcopy` on macOS
- Supports three copy methods: `y`, `Enter`, mouse drag

### 3. Added WezTerm Paste Keybindings
**File**: `config/wezterm/wezterm.lua` (lines 261-270)

**Solution**: Explicit paste keybinding using platform-aware modifier
```lua
{
  key = 'v',
  mods = mod_shift, -- CTRL+SHIFT on Windows, CMD+SHIFT on macOS
  action = wezterm.action.PasteFrom 'Clipboard',
},
```

### 4. Optimized Paste Speed
**File**: `config/wezterm/wezterm.lua` (lines 246-248)

**Problem**: Default 10ms delay between paste chunks made large pastes slow

**Solution**: Set instant paste
```lua
-- Speed up paste operations (default is 10ms between chunks, 0 = instant)
config.paste_speed = 0
```

### 5. Fixed Bracketed Paste Mode
**File**: `config/zsh/settings.zsh` (lines 7-10)

**Problem**: Heavy `bracketed-paste-magic` widget caused paste lag

**Solution**: Lightweight bracketed paste configuration
```zsh
# Enable bracketed paste mode for safe pasting
# Use lighter configuration for better performance
zstyle ':bracketed-paste-magic' active-widgets '.self-insert'
```

**Note**: Removed slow `autoload -Uz bracketed-paste-magic` and `zle -N` calls

---

## Testing Results

### ✅ Copy from tmux → Windows
**Methods Tested**:
1. `y` in copy mode (yank) - ✅ Works
2. `Enter` in copy mode - ✅ Works
3. Mouse drag selection - ✅ Works

**Workflow**:
1. Press `Ctrl+S` then `[` to enter copy mode
2. Navigate with `hjkl`, select with `v`
3. Press `y` to copy
4. Paste in any Windows app with `Ctrl+V`

### ✅ Paste from Windows → tmux
**Method**: `Ctrl+Shift+V` in WezTerm

**Performance**: Blazing fast (instant)

**Tested**:
- Small text snippets - ✅ Works
- Large code blocks - ✅ Works, instant
- Paste into naked shell - ✅ Works
- Paste into tmux pane - ✅ Works

---

## Files Modified

### Configuration Files
1. **config/tmux/tmux.conf**
   - Lines 14-16: Cross-platform shell detection
   - Lines 212-220: Platform-specific clipboard integration

2. **config/wezterm/wezterm.lua**
   - Lines 261-270: Paste keybindings
   - Lines 242-248: Paste speed optimization and keyboard compatibility

3. **config/zsh/settings.zsh**
   - Lines 7-10: Optimized bracketed paste

### Documentation Files
4. **docs/clipboard-integration-test.md** (new)
   - Complete testing guide
   - Troubleshooting tips
   - Implementation details

5. **docs/ROADMAP.md**
   - Lines 923-945: Marked clipboard integration complete

6. **docs/sessions/2025-11-23-wsl2-clipboard-integration.md** (this file)

---

## Technical Details

### Platform Detection
```bash
# WSL2 detection
uname -r | grep -i microsoft
# Returns 0 (true) on WSL2, returns non-zero on native Linux/macOS
```

### Clipboard Tools
- **WSL2**: `clip.exe` at `/mnt/c/Windows/system32/clip.exe`
- **macOS**: `pbcopy` via `reattach-to-user-namespace`
- **Alternative**: `win32yank` (faster, purpose-built) - not installed yet

### Copy Flow
```
tmux copy mode (y/Enter/mouse)
  → tmux copy-pipe-and-cancel
  → clip.exe
  → Windows clipboard
  → Available to all Windows apps
```

### Paste Flow
```
Windows app (Ctrl+C)
  → Windows clipboard
  → WezTerm (Ctrl+Shift+V)
  → PasteFrom 'Clipboard'
  → WSL2 shell/tmux pane
```

---

## Performance Metrics

### Before Optimization
- Paste speed: **Slow** (10ms per chunk + bracketed-paste-magic overhead)
- User experience: Noticeable lag on large pastes

### After Optimization
- Paste speed: **Instant** (0ms delay)
- User experience: Blazing fast, no perceptible lag

### Optimizations Applied
1. `paste_speed = 0` (WezTerm)
2. Removed `bracketed-paste-magic` widget (zsh)
3. Disabled advanced keyboard protocols for compatibility

---

## Known Limitations & Future Improvements

### Current Limitations
1. **Paste Direction**: Windows → tmux works via WezTerm, not tmux directly
   - This is by design - terminal emulator handles paste
   - `Ctrl+S` then `]` pastes from tmux buffer, not Windows clipboard

2. **Clipboard Tool**: Using `clip.exe` which works but could be faster

### Potential Improvements
1. **Install win32yank**: Purpose-built clipboard tool for WSL2
   - Potentially faster than `clip.exe`
   - Better Windows integration
   - Installation: `cargo install win32yank` or download binary

2. **Tmux Plugin Alternative**: Consider `tmux-yank` plugin enhancements
   - Already installed but might have additional config options

3. **Middle-Click Paste**: Add mouse binding for middle-click paste
   - Traditional Unix paste behavior
   - Would complement Ctrl+Shift+V

---

## Integration with Existing Features

### Works With
- ✅ Tmux copy mode (vim keybindings)
- ✅ WezTerm leader key (`Ctrl+Space`)
- ✅ Tmux leader key (`Ctrl+S`)
- ✅ Unified window/pane management keybindings
- ✅ Mouse mode in tmux
- ✅ Cross-platform shell configuration

### No Conflicts With
- ✅ Vim keybindings
- ✅ Tmux plugins (tmux-yank, etc.)
- ✅ Zsh plugins
- ✅ Existing WezTerm keybindings

---

## Troubleshooting Guide

### Issue: Paste shows `^[[200~` escape codes
**Cause**: Bracketed paste mode not handled by shell
**Solution**: Source updated zsh config or restart shell
```bash
source ~/.config/zsh/settings.zsh
```

### Issue: Paste is slow
**Cause**: Old WezTerm config or zsh bracketed-paste-magic
**Solution**:
1. Reload WezTerm config: `Ctrl+Space` then `r`
2. Restart shell or source config

### Issue: Copy doesn't work
**Cause**: Not in copy mode or wrong keybinding
**Solution**:
1. Enter copy mode: `Ctrl+S` then `[`
2. Select text with `v` and `hjkl`
3. Press `y` to copy

### Issue: `clip.exe` not found
**Cause**: Not on WSL2 or clip.exe path changed
**Solution**: Verify WSL2 and clip.exe location
```bash
uname -r  # Should contain "microsoft"
which clip.exe  # Should return /mnt/c/Windows/system32/clip.exe
```

---

## Next Steps

### Immediate (Completed)
- [x] Bidirectional clipboard working
- [x] Paste speed optimized
- [x] Documentation created
- [x] ROADMAP updated

### Future Enhancements (Optional)
- [ ] Install `win32yank` for potentially better performance
- [ ] Add middle-click paste support
- [ ] Document clipboard workflow in main README
- [ ] Test on different WSL distributions (Debian, Arch, etc.)

---

## Related Documentation

- **Testing Guide**: `docs/clipboard-integration-test.md`
- **Project Roadmap**: `docs/ROADMAP.md` (lines 923-945)
- **Previous WSL Session**: `docs/sessions/2025-11-20-wsl2-ubuntu-installation.md`
- **WezTerm Session**: `docs/sessions/2025-11-21-wezterm-wsl-cross-platform-fixes.md`

---

## Key Learnings

1. **Platform Detection**: `uname -r | grep -i microsoft` is reliable for WSL2 detection
2. **Paste Speed**: Default 10ms delay is noticeable; setting to 0 is fine for modern systems
3. **Bracketed Paste**: The `bracketed-paste-magic` widget is slow; use lighter alternatives
4. **Cross-Platform**: Always use conditional logic for platform-specific paths
5. **Clipboard Direction**: Copy goes through tmux, paste goes through terminal emulator

---

## Commands Reference

### Copy from tmux
```bash
# Enter copy mode
Ctrl+S then [

# Navigate and select
hjkl          # Navigate
v             # Start visual selection
y             # Yank (copy) and exit
Enter         # Alternative copy and exit
```

### Paste into tmux
```bash
# From Windows clipboard
Ctrl+Shift+V  # Paste in WezTerm

# From tmux buffer
Ctrl+S then ] # Paste from tmux buffer (not Windows clipboard)
```

### Reload Configurations
```bash
# Reload tmux config
Ctrl+S then r

# Reload WezTerm config
Ctrl+Space then r

# Reload zsh config
source ~/.config/zsh/settings.zsh
```

---

## Session Timeline

1. **Context Gathering** (10 min)
   - Read ROADMAP.md and session documentation
   - Identified clipboard integration as priority task

2. **Copy Implementation** (15 min)
   - Fixed cross-platform shell detection
   - Added WSL2-specific clipboard integration
   - Tested copy from tmux to Windows - ✅ Working

3. **Paste Implementation** (20 min)
   - Added WezTerm paste keybindings
   - Fixed bracketed paste escape sequences
   - Initial paste working but slow

4. **Performance Optimization** (15 min)
   - Set `paste_speed = 0` in WezTerm
   - Removed slow `bracketed-paste-magic` widget
   - Result: Blazing fast paste

5. **Documentation** (20 min)
   - Created testing guide
   - Updated ROADMAP
   - Created session documentation

**Total Time**: ~80 minutes

---

## Success Criteria - All Met ✅

- [x] Copy from tmux to Windows clipboard works
- [x] Paste from Windows to tmux works
- [x] Paste is fast (no perceptible lag)
- [x] Works in both naked shell and tmux panes
- [x] Cross-platform compatible (macOS + WSL2)
- [x] No conflicts with existing keybindings
- [x] Fully documented

---

**Status**: Production Ready
**Date Completed**: November 23, 2025
**Next Session**: WSL2 Performance Optimization (shell startup, git, .wslconfig)
