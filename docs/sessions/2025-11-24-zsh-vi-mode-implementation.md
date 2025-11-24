# ZSH Vi-Mode Implementation

**Date:** 2025-11-24
**Status:** Completed - Ready for real-world testing

---

## Summary

Implemented zsh-vi-mode for vim-like editing in the zsh command line, replacing the previous emacs-mode with Alt+hjkl workaround.

## Changes Made

### Files Modified

1. **`zinitrc`** - Added zsh-vi-mode plugin:
   ```zsh
   zinit light jeffreytse/zsh-vi-mode
   ```

2. **`config/zsh/keybindings.zsh`** - Complete rewrite for vi-mode:
   - Configured zsh-vi-mode settings (cursor styles, timeouts)
   - Preserved essential emacs bindings in insert mode
   - Added `Ctrl+G` as escape to normal mode
   - Removed Alt+hjkl bindings (redundant with normal mode)

3. **`config/nvim/lua/config/keymaps.lua`** - Added matching nvim binding:
   ```lua
   imap({ "<C-g>", "<Esc>", { desc = "Exit insert mode" } })
   ```

### Key Bindings

**Insert Mode:**
| Binding | Action |
|---------|--------|
| `Ctrl+G` | Exit to normal mode |
| `Ctrl+A` | Beginning of line |
| `Ctrl+E` | End of line |
| `Ctrl+K` | Kill to end of line |
| `Ctrl+W` | Delete word backward |
| `Ctrl+U` | Delete to start of line |
| `Ctrl+L` | Clear screen |
| `Ctrl+R` | History search |
| `Ctrl+P/N` | Previous/next history |
| `Ctrl+F` | Accept entire autosuggestion |
| `Ctrl+Y` | Accept autosuggestion word-by-word |
| `→` | Accept autosuggestion char-by-char |
| `Ctrl+→/←` | Forward/backward word |

**Normal Mode:**
Standard vim bindings work: `hjkl`, `w/b/e`, `0/$`, `i/a/A/I`, `x`, `dd`, `dw`, `cw`, `ciw`, `u`, `/`, `f/t`, `p`, etc.

## Issues Encountered & Resolutions

1. **`jk` escape timing unreliable** → Used `Ctrl+G` instead
2. **`Ctrl+C` intercepted by SIGINT** → Can't override at shell level
3. **FZF widgets not found** → Added conditional check for widget existence
4. **Alt+hjkl not working consistently** → Removed (redundant with normal mode)

## Testing Results

- ✅ All insert mode bindings working
- ✅ All normal mode vim operations working
- ✅ Autosuggestions work across mode switches
- ✅ fzf-tab completion working
- ✅ No binding conflicts detected
- ✅ Shell startup: ~540ms (acceptable)

## Future Improvements (Roadmap)

- [ ] Set up FZF key-bindings for `Ctrl+R` fuzzy history search
- [ ] Investigate shell startup optimization (target < 500ms)
- [ ] Consider adding surround operations in normal mode
- [ ] Update README.md keybinding documentation

## Related Files

- `docs/PROMPT_BUFFER_NAVIGATION_KEYBIND_UNIFICATION.md` - Original planning doc
- `docs/sessions/2025-11-24-zsh-vi-mode-testing-audit.md` - Testing checklist

## Notes

- `Ctrl+G` chosen because it's ergonomic with Caps Lock → Ctrl remap
- Cursor changes shape: beam in insert mode, block in normal mode
- This matches the cross-tool keybinding unification strategy (vim/tmux/WezTerm)
