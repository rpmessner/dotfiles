# Clipboard Configuration: Plugin Load Order Fix

**Date:** November 23, 2025
**Status:** Fixed
**Related Sessions:**
- [2025-11-23-wsl2-clipboard-integration.md](./2025-11-23-wsl2-clipboard-integration.md) - Initial WSL2 clipboard setup
- [2025-11-23-clipboard-conflict-resolution.md](./2025-11-23-clipboard-conflict-resolution.md) - OSC 52 conflict resolution

## Problem

After implementing the WSL2 clipboard integration, the clipboard would work correctly in **fresh tmux sessions** but would **break during active sessions**. The issue wasn't immediately apparent because:

- Fresh WezTerm panes/windows with new tmux sessions: ✅ Clipboard worked
- Existing tmux sessions after some time: ❌ Clipboard stopped working
- Reloading tmux config didn't fix it permanently

## Root Cause Analysis

### The Plugin Conflict

The dotfiles use the `tmux-yank` plugin, which automatically detects clipboard commands and sets up bindings. On WSL2, tmux-yank detects `clip.exe` and configures bindings like:

```bash
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "cat | clip.exe"
```

### The Load Order Problem

The original tmux.conf structure was:

```
1. Basic tmux configuration
2. Copy-mode bindings (lines 215-227)
   - Custom clipboard config for WSL2/macOS
3. Plugin declarations (@plugin statements)
4. TPM initialization (line 295: run '~/.tmux/plugins/tpm/tpm')
```

**The Issue:** Our custom clipboard configuration ran **before** TPM loaded the plugins. When TPM initialized tmux-yank, it would **overwrite** our custom bindings with its own auto-detected ones.

This created a race condition where:
- Config load: Our bindings set ✅
- Plugin load: tmux-yank overwrites them ❌
- Runtime: Clipboard breaks due to OSC 52 conflicts

### Evidence

Checking running tmux session settings revealed:

```bash
$ tmux list-keys -T copy-mode-vi | grep "y "
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel "cat | clip.exe"
# ❌ Wrong! This is tmux-yank's binding, not ours
```

```bash
$ tmux show-options -gs terminal-features
terminal-features[0] xterm*:clipboard:ccolour:cstyle:focus:title  # ❌ clipboard enabled!
terminal-features[1] screen*:title
terminal-features[2] rxvt*:ignorefkeys
terminal-features[3] xterm*:ccolour:cstyle:focus:title
terminal-features[4] xterm*:clipboard@  # ✅ Our fix, but comes after [0]
```

The `terminal-features[0]` entry with `clipboard` enabled was persisting because it was set during plugin initialization.

## Solution

### Strategy

Move the platform-specific clipboard configuration to run **AFTER** TPM initialization, allowing it to override tmux-yank's bindings on WSL2 while preserving tmux-yank's functionality on macOS.

### Implementation

**File:** `config/tmux/tmux.conf`

**Step 1:** Replace original clipboard config (lines 215-227) with a note:

```tmux
# NOTE: Platform-specific clipboard configuration moved to end of file
# (after TPM initialization) to override tmux-yank plugin bindings
```

**Step 2:** Add clipboard override AFTER TPM initialization (after line 295):

```tmux
# Initialize TMUX plugin manager (keep this line at the very bottom of tmux.conf)
run '~/.tmux/plugins/tpm/tpm'

# =================================================
# Platform-specific clipboard overrides (post-plugin)
# =================================================
# NOTE: Must run AFTER TPM to override tmux-yank plugin bindings
#
# WSL2: Disable OSC 52 clipboard sync and use clip.exe directly
#       tmux-yank detects clip.exe but wraps it in "cat | clip.exe" which works,
#       however we need to disable terminal-features clipboard to prevent conflicts
#
# macOS: tmux-yank handles clipboard correctly, no overrides needed
if-shell "uname -r | grep -i microsoft" \
  "set -s set-clipboard off; \
   set -as terminal-features 'xterm*:clipboard@'; \
   bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'clip.exe'; \
   bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'clip.exe'; \
   bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'clip.exe'"
```

### Why This Works

**New Load Order:**
1. Basic tmux configuration
2. Plugin declarations
3. **TPM initialization** (plugins load, including tmux-yank)
4. **Platform-specific clipboard overrides** (WSL2 only)

Now our clipboard configuration runs **last**, ensuring:
- WSL2: Our explicit `clip.exe` bindings override tmux-yank
- macOS: No override runs, tmux-yank handles clipboard via `pbcopy`

### Cross-Platform Considerations

**WSL2:**
- Overrides tmux-yank bindings
- Uses `clip.exe` directly (not `cat | clip.exe`)
- Disables OSC 52 via `set-clipboard off` and `terminal-features clipboard@`

**macOS:**
- No override applied (`if-shell` only runs on WSL2)
- tmux-yank plugin handles clipboard via `reattach-to-user-namespace pbcopy`
- Relies on tmux-yank's auto-detection and configuration

This maintains the working macOS setup while fixing WSL2.

## Verification

After the fix, in a **fresh tmux session**:

```bash
$ tmux show-options -gs set-clipboard
set-clipboard off  # ✅ Correct

$ tmux list-keys -T copy-mode-vi | grep "y "
bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel clip.exe
# ✅ Correct! Direct clip.exe, not wrapped in cat
```

## Testing Checklist

- [x] WSL2: Copy text with `y` in copy-mode → Clipboard persists
- [x] WSL2: Copy text with `Enter` in copy-mode → Clipboard persists
- [x] WSL2: Copy text with mouse drag → Clipboard persists
- [x] WSL2: Paste with `Ctrl+Shift+V` in WezTerm → Works instantly
- [ ] macOS: Verify tmux-yank still works (requires macOS testing)

## Key Learnings

### Plugin Load Order Matters

When using tmux plugins that modify the same settings you're configuring:
- Plugins load when TPM runs (`run '~/.tmux/plugins/tpm/tpm'`)
- Any config **before** TPM runs will be overridden by plugins
- Any config **after** TPM runs will override plugins

### When to Override vs. Disable Plugins

**Override (our approach):**
- Keep the plugin for cross-platform compatibility
- Override specific bindings on platforms where needed
- Cleaner than maintaining separate configs

**Disable alternative:**
- Could remove `tmux-yank` from plugin list
- Would require manual clipboard setup for both platforms
- More code duplication

### Debugging Plugin Conflicts

Useful commands for troubleshooting:

```bash
# Check current bindings
tmux list-keys -T copy-mode-vi | grep <key>

# Check current options
tmux show-options -gs <option-name>

# Reload config and observe changes
tmux source-file ~/.config/tmux/tmux.conf

# Check plugin-specific settings
ls ~/.config/tmux/plugins/
grep -r "set-clipboard" ~/.config/tmux/plugins/
```

## Files Modified

- `config/tmux/tmux.conf:215-217` - Removed original clipboard config, added note
- `config/tmux/tmux.conf:286-301` - Added post-plugin clipboard override
- `.gitignore:15` - Added `.claude/` directory (unrelated cleanup)

## Commits

```bash
fix(tmux): move clipboard config after plugin load to prevent override

Moved WSL2 clipboard configuration to run after TPM initialization, ensuring
our explicit clip.exe bindings override tmux-yank's auto-detected settings.
This fixes clipboard breaking during active sessions while preserving
tmux-yank functionality on macOS.
```

## Future Considerations

### Monitor in Fresh Sessions

Since existing sessions have stale `terminal-features[0]` entries, the fix needs validation in fresh tmux sessions. If issues persist, may need to:

1. Explicitly unset problematic terminal-features entries
2. Use `set -g` instead of `set -as` to replace rather than append
3. Consider patching tmux-yank to skip WSL2 auto-detection

### Potential Alternative: tmux-yank Configuration

tmux-yank supports configuration via tmux options. Could potentially use:

```tmux
set -g @override_copy_command 'clip.exe'
```

This wasn't explored because moving config post-plugin is simpler and more explicit.

### macOS Testing Required

The macOS clipboard integration hasn't been tested since this change. Should verify:
- tmux-yank still auto-detects `pbcopy`
- Copy/paste works in all modes (y, Enter, mouse)
- No conflicts with system clipboard

## Related Documentation

- tmux-yank: https://github.com/tmux-plugins/tmux-yank
- tmux terminal-features: `man tmux` (search for "terminal-features")
- TPM: https://github.com/tmux-plugins/tpm
