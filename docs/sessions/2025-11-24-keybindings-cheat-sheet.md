# Keybindings Cheat Sheet Creation

**Date:** 2025-11-24
**Status:** Completed

---

## Summary

Created a comprehensive keybindings cheat sheet (`KEYBINDINGS.md`) documenting all custom keybindings across Zsh, Neovim, tmux, and WezTerm.

## Files Created

1. **`KEYBINDINGS.md`** - Comprehensive keybindings reference at project root

## Sections Documented

### Unified Window/Pane Management
- Cross-tool pattern table (Vim, tmux, WezTerm)
- Navigate, swap, resize, zoom, equalize, rotate, last-active bindings
- Modifier pattern explanation (hjkl → HJKL → Ctrl+hjkl)

### Zsh (Vi-Mode)
- Mode switching (`Ctrl+G`, `jk`)
- Insert mode emacs-style bindings preserved
- Autosuggestion acceptance bindings
- FZF integration (`Ctrl+R`, `Ctrl+T`)

### tmux (Prefix: Ctrl+S)
- Pane management (split, navigate, swap, resize, zoom)
- Window/tab management
- Copy mode with vim bindings
- Plugin bindings (Thumbs, Extrakto, fuzzy panes)

### WezTerm (Leader: Ctrl+Space)
- Pane and tab management
- Copy/paste (platform-aware)
- Copy mode vim bindings
- Quick select for URLs/paths

### Neovim (Leader: Space)
- Window management
- Oil.nvim file navigation
- Snacks.picker finder bindings
- LSP bindings
- Git (Fugitive, Diffview)
- Clipboard operations
- vim-test bindings
- Flash motion
- Trouble diagnostics
- Claude Code AI integration
- Visual mode operations

### Quick Reference
- Leader key summary for each tool
- Mode escape patterns
- Consistent binding patterns across tools

## Sources Interrogated

- `config/zsh/keybindings.zsh` - Zsh vi-mode configuration
- `config/tmux/tmux.conf` - tmux keybindings
- `config/wezterm/wezterm.lua` - WezTerm keybindings
- `config/nvim/lua/config/keymaps.lua` - Neovim custom keymaps
- `config/nvim/lua/plugins/snacks.lua` - Picker keybindings
- `config/nvim/lua/plugins/oil.lua` - Oil.nvim keybindings
- `README.md` - Existing unified keybinding documentation

## Notes

- Document is ~400 lines, comprehensive but may benefit from trimming
- Follows the unified keybinding philosophy established in README.md
- Includes both custom bindings and important defaults
- Organized by tool for easy reference
