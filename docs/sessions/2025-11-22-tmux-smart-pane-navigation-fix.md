# Tmux Smart Pane Navigation Fix

**Date**: November 22, 2025
**Duration**: ~15 minutes
**Status**: Complete ✅

---

## Overview

Fixed unintuitive behavior in tmux's smart pane navigation where up/down movements were applying "leftmost preference" logic, causing unexpected jumps when navigating between horizontally-split panes.

## Problem

The smart pane selection script (`scripts/tmux-smart-select-pane.sh`) was applying topmost/leftmost preference logic to ALL directions (up, down, left, right). This caused problems when navigating vertically:

### Reproduction Case

```
+----------+----------+
|  TL (1)  |  TR (2)  |
|          |----------|
|----------|  MR (3)  |
|  BL (4)  |----------|
|          |  BR (5)  |
+----------+----------+
```

**Issue**: From Bottom-Left (BL), pressing `<leader>k` (up) would jump to Top-Right (TR) instead of Top-Left (TL).

**Root Cause**: The script's upward navigation logic was finding all panes above the current position, then selecting the *leftmost* one. Since TR was considered "above" BL (by virtue of having a top edge above BL's bottom edge), it would sometimes be selected over TL.

## Solution

Removed smart logic from up/down navigation entirely. The script now:

- **Left/Right (h/l)**: Uses smart logic to always go to the **topmost** pane on that side (desired behavior for crossing vertical splits)
- **Up/Down (k/j)**: Uses **tmux's default behavior** (intuitive movement to the pane directly above/below)

### Code Changes

**File**: `scripts/tmux-smart-select-pane.sh`

Replaced the U/D case branches with a simple fallthrough:

```bash
U|D) # Up/Down: use tmux's default behavior (no smart logic)
  # Return empty to fall through to default
  ;;
```

This allows up/down navigation to skip the smart selection logic and fall through to tmux's built-in `select-pane -U` or `select-pane -D` behavior.

## Design Rationale

The original intent of smart pane selection was to make cross-split navigation consistent:
- When moving **left/right across vertical splits**, always land on the topmost pane
- This creates predictable behavior when you have multiple horizontal splits on each side

However, applying similar logic to up/down navigation:
- Creates unintuitive behavior (users expect to move to the pane directly above/below)
- Adds unnecessary complexity for a case that doesn't need "smart" handling
- Tmux's default up/down selection is already optimal

## Testing

Tested with the reproduction case above:
- ✅ From BL, `<leader>k` now correctly moves to TL (directly above)
- ✅ From BL, `<leader>l` still moves to TR (topmost pane on right side)
- ✅ From MR, `<leader>h` still moves to TL (topmost pane on left side)
- ✅ From MR, `<leader>k` correctly moves to TR (directly above)

## Files Modified

1. `scripts/tmux-smart-select-pane.sh` - Removed smart logic for U/D navigation
2. `docs/ROADMAP.md` - Marked unified pane management as complete, removed action item

## Related Context

This fix completes the unified pane/window management system implemented on 2025-11-22 (see `docs/sessions/2025-11-22-macos-unified-keybind-fixes-and-rust-consolidation.md`). The unified system provides consistent keybindings across vim, tmux, and WezTerm for:
- Navigate: `hjkl`
- Swap/Move: `HJKL`
- Resize: `Ctrl+hjkl`
- Zoom: `z`
- Equalize: `=`
- Rotate: `R`
- Last Active: `;`

This fix ensures the navigation component works intuitively for all layout configurations.

## Commit Message

```
fix(tmux): remove smart logic from up/down pane navigation

The smart pane selection script was applying topmost/leftmost preference
to all directions, causing unintuitive behavior when navigating vertically
between horizontally-split panes.

Now only left/right navigation uses smart "topmost pane" selection, while
up/down uses tmux's default behavior for intuitive movement.

Fixes navigation issue where moving up from a bottom pane would jump to
an unexpected pane on the opposite side of a vertical split.
```

## Outcome

- ✅ Up/down navigation now behaves intuitively (moves to pane directly above/below)
- ✅ Left/right navigation retains smart "topmost pane" behavior (desired for vertical splits)
- ✅ Zero regressions in existing unified keybinding system
- ✅ Completed outstanding action item from ROADMAP.md

---

**Session Type**: Bug Fix
**Impact**: Medium - Improves daily navigation UX in tmux
**Complexity**: Low - Simple surgical fix
