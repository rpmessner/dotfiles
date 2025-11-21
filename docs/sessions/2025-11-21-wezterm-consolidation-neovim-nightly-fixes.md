# Session: WezTerm Consolidation & Neovim Nightly Compatibility

**Date:** 2025-11-21
**Context:** Cross-platform dotfiles standardization effort

## Overview

This session focused on standardizing terminal emulator usage to WezTerm only and resolving Neovim nightly compatibility issues. These changes support the broader goal of making dotfiles properly cross-platform and reducing maintenance complexity.

## Cross-Platform Context

As part of the effort to make dotfiles work seamlessly across macOS, Linux, and WSL:

- **Terminal Standardization:** Consolidating on WezTerm as the sole terminal emulator reduces platform-specific configuration and testing burden
- **Global Linting:** Moving markdown linting configs to global scope ensures consistent behavior across all projects and platforms
- **Neovim Nightly:** Maintaining compatibility with latest Neovim features while ensuring stability across different architectures (arm64/x86_64)

## Problems Solved

### 1. Multiple Terminal Emulators

**Issue:** Dotfiles maintained configurations for multiple terminal emulators (alacritty, ghostty, kitty, wezterm), creating:
- Maintenance overhead
- Inconsistent behavior across configs
- Unnecessary symlinks and Brewfile entries

**Solution:** Removed all terminal emulators except WezTerm

**Files Modified:**
- `Brewfile` - Removed ghostty cask
- `aliases` - Removed kittyconfig alias
- `scripts/term.sh` - Removed alacritty-direct from terminfo
- `config/tmux/tmux.conf` - Removed alacritty terminal-features
- `CLAUDE.md` - Updated to show WezTerm only
- `README.md` - Changed terminal reference to WezTerm
- `installer.rb` - Removed kitty/alacritty from symlink dirs
- Deleted: `config/alacritty/`, `config/ghostty/`, `config/kitty/`

**Benefits:**
- Single source of truth for terminal configuration
- Easier cross-platform maintenance
- WezTerm has excellent cross-platform support (macOS, Linux, Windows)

### 2. Markdown Linting Configuration

**Issue:** Recent upstream commit made markdown linting files global, needed verification

**Verification:**
- Confirmed `markdownlint.jsonc` and `markdownlint-cli2.jsonc` properly symlinked
- Files correctly placed without leading dots in repo
- Symlinked with dots in home directory for tool discovery
- Configuration chain working: `markdownlint-cli2.jsonc` → `markdownlint.jsonc`

**Configuration:**
- Ignores CHANGELOG.md (auto-generated)
- Relaxed rules for documentation (no line length limits, allow bare URLs)
- Enforces consistency (ATX headings, dash lists, 2-space indent)

### 3. Neovim Nightly Treesitter Architecture Mismatch

**Issue:** Opening markdown files triggered error:
```
Failed to load parser for language 'markdown':
mach-o file, but is an incompatible architecture
(have 'x86_64', need 'arm64e' or 'arm64')
```

**Root Cause:** Treesitter parsers compiled for x86_64 (Intel) but running on arm64 (Apple Silicon)

**Solution:**
```bash
rm -rf ~/.local/share/nvim/site/parser
rm -rf ~/.local/share/nvim/lazy/nvim-treesitter
# Then in Neovim:
:Lazy sync
:TSInstall! all
```

**Created:** `config/nvim/lua/plugins/nvim-treesitter.lua`
- Forces latest git commit for nightly compatibility
- Auto-installs parsers
- Ensures core parsers (lua, vim, markdown, etc.) are present

**Cross-Platform Note:** This issue commonly occurs when:
- Running Neovim under Rosetta emulation
- Migrating dotfiles between Intel and Apple Silicon Macs
- Solution works across all architectures by forcing clean rebuild

### 4. Neovim Nightly Query Module Error

**Issue:** Pressing any key in Neovim triggered:
```
.../nightly/share/nvim/runtime/lua/vim/treesitter/query.lua:3 "substitute"
```

**Root Cause:** noice.nvim's treesitter markdown rendering overrides incompatible with Neovim 0.12.0-dev

**Solution:**
- Updated treesitter parsers to latest versions
- Ensured noice.nvim tracking main branch for nightly compatibility
- Re-enabled LSP markdown rendering after parsers updated

**Version Context:** Neovim 0.12.0-dev-1673+g7be031f397

### 5. Unwanted Prose Linting Warnings

**Issue:** Opening markdown files showed unconfigurable warnings:
- "Consider using an m-dash if you do not want to join two words"
- Serial comma warnings

**Root Cause:** LazyVim's `lang.markdown` extra auto-installs prosemd-lsp

**Investigation:**
- prosemd-lsp has no configuration file support
- No way to disable specific rules
- Limited to `--stdio` and `--socket` CLI flags

**Solution:** Created `config/nvim/lua/plugins/disable-prosemd.lua`
```lua
{
  "neovim/nvim-lspconfig",
  opts = {
    servers = {
      prosemd_lsp = {
        mason = false,  -- Don't install via Mason
        enabled = false, -- Disable entirely
      },
    },
  },
}
```

**Retained:**
- marksman - Markdown LSP for navigation/symbols
- markdownlint-cli2 - Configurable markdown linting

## Files Changed Summary

### New Files
- `config/nvim/lua/plugins/nvim-treesitter.lua` - Nightly compatibility config
- `config/nvim/lua/plugins/disable-prosemd.lua` - Disable unconfigurable prose linter
- `docs/sessions/2025-11-21-wezterm-consolidation-neovim-nightly-fixes.md` - This document

### Modified Files
- `Brewfile` - Removed ghostty
- `aliases` - Removed kittyconfig
- `config/tmux/tmux.conf` - Removed alacritty support
- `scripts/term.sh` - Removed alacritty from terminfo
- `CLAUDE.md` - Updated terminal reference
- `README.md` - Updated terminal reference
- `installer.rb` - Removed kitty/alacritty symlinks
- `markdownlint.jsonc` - Added MD044, MD052, MD053 rules
- `config/nvim/lua/plugins/noice.lua` - Re-enabled after fixes

### Deleted Files/Directories
- `config/alacritty/` (9 files)
- `config/ghostty/` (1 file)
- `config/kitty/` (1 file)

## Cross-Platform Testing Checklist

When applying these changes to other platforms:

- [ ] **macOS (arm64)** - Tested ✅
- [ ] **macOS (x86_64)** - Should work, may need parser rebuild
- [ ] **Linux (Debian/Ubuntu)** - Test WezTerm availability, treesitter builds
- [ ] **WSL** - Verify WezTerm integration, may need different terminal approach

## Lessons Learned

1. **Architecture Matters:** Always rebuild native extensions (treesitter parsers) when switching architectures
2. **LazyVim Extras:** When using LazyVim extras, check what they auto-install and override if needed
3. **Global Configs:** Placing linting configs globally (without dots in repo) is cleaner and works well with symlinks
4. **Nightly Trade-offs:** Running Neovim nightly requires vigilance with plugin compatibility and parser updates

## Future Improvements

1. **Automated Parser Rebuilds:** Add task command to rebuild treesitter parsers for current architecture
2. **Cross-Platform Terminal Config:** Document WezTerm-specific features being used and alternatives for platforms where WezTerm may not be ideal
3. **CI Testing:** Add CI checks to ensure markdown linting rules are enforced across all docs
4. **Nightly Version Pinning:** Consider pinning Neovim nightly to specific commit if stability is priority

## Related Sessions

- Previous sessions on Neovim configuration (check `docs/sessions/` for 2025-11-21-* files)
- Future: Cross-platform dotfiles testing and validation

## Commands Reference

### Rebuild Treesitter Parsers
```vim
:Lazy sync
:TSUpdate all
:TSInstall! all  # Force clean rebuild
```

### Check Architecture
```bash
uname -m  # Shows: arm64 or x86_64
```

### Verify LSPs Running
```bash
ps aux | grep -E "lsp|language-server"
```

### Test Markdown Linting
```bash
# In any directory
markdownlint-cli2 README.md

# In Neovim - diagnostics should appear automatically
```
