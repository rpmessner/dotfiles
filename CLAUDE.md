# Claude Code Integration Guide

This document provides context and guidance for Claude Code when working with this dotfiles repository.

## Repository Overview

This is Ryan's personal dotfiles repository, a comprehensive development
environment configuration for macOS, Linux and Windows WSL. Originally forked
from [Dorian Karter's dotfiles](https://github.com/dkarter/dotfiles) and
extensively customized. The repository follows a modern, structured approach
using Task automation and asdf for dependency management.

### Architecture & Organization

**Core Philosophy:**

- Automated installation and synchronization
- XDG Base Directory compliance (most configs in `config/`)
- Cross-platform support (macOS, Ubuntu/WSL2) - **Note: Debian support removed, focus on Ubuntu + macOS**
- Modern tooling with performance focus
- Conventional commits and semantic versioning
- **Unified keybindings:** Consistent window/pane management across vim, tmux, and WezTerm (see README.md for details)

**Primary Development Platform (as of Nov 2025):**

- **Windows 11 + WSL2 (Ubuntu 24.04)** - Active development environment
- **macOS** - Secondary platform (less frequently used)
- **Platform-specific optimizations**: See `docs/wsl2-performance-roadmap.md` for WSL2 performance tuning

**Directory Structure:**

```
├── config/                # XDG-compliant configuration files
│   ├── nvim/              # Neovim configuration (Lua-based)
│   ├── tmux/              # Terminal multiplexer config
│   ├── zsh/               # Z shell configurations
│   ├── wezterm/           # Terminal emulator config
│   ├── hammerspoon/       # macOS automation (Lua)
│   └── [various tools]/   # Tool-specific configurations
├── docs/                  # Documentation
│   └── sessions/          # Development session notes (see below)
├── taskfiles/             # Task automation definitions
├── installer/             # Platform-specific setup scripts
├── scripts/               # Utility scripts
└── [dotfiles]             # Home directory dotfiles (no dot prefix)
```

**Session Documentation (`docs/sessions/`):**

This directory contains detailed notes from development/configuration sessions. When
asked about previous work, custom features, or "how was X implemented", check this
folder for session documentation. Each file follows the format:
`YYYY-MM-DD-descriptive-name.md`

## Key Technologies & Tools

### Core Development Stack

- **Editor:** Neovim (modern Lua configuration)
- **Terminal:** WezTerm
- **Shell:** Zsh with custom configuration
- **Multiplexer:** tmux with extensive plugin ecosystem
- **Version Control:** Git with conventional commits

### Package Management

- **Homebrew:** GUI applications (casks) and system libraries
- **asdf:** Runtime management (Node, Ruby, Python, etc.)
- **pnpm:** Node.js package management
- **Mason:** Neovim LSP/formatter/linter management

### Automation & Build

- **Task:** Modern Makefile alternative for automation
- **Lefthook:** Git hooks management
- **Conventional Commits:** Standardized commit messages checked with `committed` CLI
- **Release Please:** Automated semantic versioning through GitHub Actions

## Installation & Setup

### Initial Installation

```bash
git clone git@github.com:rpmessner/dotfiles.git
cd dotfiles
./setup.sh
```

### Synchronization (Updates)

```bash
git pull
task sync  # Updates tools and configurations
task nvim:commit # synchronizes neovim plugin manager lockfile (lazy-lock.json)
```

### Platform Detection

The setup script automatically detects:

- macOS (primary target)
- Linux/Debian (partial support - aim for full compatibility)

## Common Operations

### Task Commands

```bash
task -l         # List all available tasks
task install    # Full installation
task sync       # Synchronize/update everything
task ci:run     # Run all linting/checks
```

### Development Workflow

```bash
# Conventional commits are enforced via lefthook and committed
git commit -m "feat: add new feature"

# CI checks run on pre-push
git push
```

## Configuration Areas

### Neovim Configuration

- **Location:** `config/nvim/`
- **Plugin Manager:** Lazy.nvim
- **Language:** Lua with TypeScript-style organization
- **Key Features:**
  - LSP integration via Mason
  - Modern completion with cmp, has Blink.cmp but it is disabled for now
  - Git integration (Fugitive, Gitsigns)
  - AI assistance (Copilot, Code Companion)
  - File management with Oil.nvim
  - Debugging with nvim-dap

### Terminal & Shell

- **Zsh Config:** Modular files in `config/zsh/`
- **Zinit:** Zsh plugin manager
- **Starship:** Cross-shell prompt
- **FZF:** Fuzzy finding integration
- **Zoxide:** Smart directory jumping

**Key Bindings:**
- **tmux prefix:** `Ctrl+S` (primary) or `Ctrl+Z` (secondary - prevents accidental suspend)
- **WezTerm leader:** `Ctrl+Space` (terminal-level pane/tab management)
- **Suspend process:** `Ctrl+Z` works in non-tmux sessions; use `Ctrl+Space z` in WezTerm for intentional suspend in tmux
- **Unified window/pane management:** Consistent keybindings across vim (`Ctrl+W`), tmux (`Ctrl+S`), and WezTerm (`Ctrl+Space`) for navigate (hjkl), swap (HJKL), resize (Ctrl+hjkl), zoom (z), equalize (=), rotate (R), and last-active (;). See README.md "Unified Window/Pane Management" section for complete reference.

### Git Configuration

- **Conventional Commits:** Enforced via cocogitto (cog)
- **Semantic Versioning:** Automated via Release Please
- **Hooks:** Managed by Lefthook
- **Templates:** Custom commit message templates

### macOS Integration

- **Hammerspoon:** Lua-based automation
- **Raycast:** Spotlight alternative
- **HyperKey:** Modifier key setup
- **System Preferences:** Automated via Task scripts

## Development Guidelines

### Code Style & Standards

- **Lua:** Formatted with stylua
- **Shell Scripts:** Linted with shellcheck
- **YAML:** Linted with yamllint
- **Spelling:** Checked with typos
- **Commits:** Must follow conventional commit format

### Testing & CI

The CI pipeline (`task ci:run`) includes:

- Lua linting and formatting checks
- Shell script linting
- YAML validation
- Spell checking
- All checks must pass before pushing

### File Organization

- Configuration files use XDG Base Directory standard
- Dotfiles in root don't have dot prefix (symlinked with dots)
- Modular approach - break large configs into smaller files
- Platform-specific code isolated in taskfiles

## WSL2-Specific Context (Windows + Ubuntu 24.04)

### Platform Detection
The repository uses platform detection throughout for cross-platform compatibility:
- **WSL2 Detection**: `uname -r | grep -i microsoft` (returns 0 on WSL2)
- **Shell Detection**: Auto-detect zsh path (`/opt/homebrew/bin/zsh` on macOS, `/usr/bin/zsh` on Ubuntu)
- **WezTerm**: Uses `wezterm.target_triple` for platform-specific keybindings

### Clipboard Integration ✅ (Completed Nov 23, 2025)
**Status**: Fully functional and optimized

**Copy from tmux → Windows**:
- Uses `clip.exe` at `/mnt/c/Windows/system32/clip.exe`
- Works with: `y` (yank), `Enter`, mouse drag in copy mode
- Configuration: `config/tmux/tmux.conf` (lines 212-220)

**Paste from Windows → tmux**:
- Keybinding: `Ctrl+Shift+V` in WezTerm
- Performance: Instant (0ms delay with `paste_speed = 0`)
- Configuration: `config/wezterm/wezterm.lua` (lines 261-270, 246-248)

**Session**: `docs/sessions/2025-11-23-wsl2-clipboard-integration.md`

### Performance Optimization Roadmap
**Status**: Planned for implementation

**Primary Document**: `docs/wsl2-performance-roadmap.md`

**Priorities**:
1. ⏳ Establish performance baseline (Week 1)
2. ⏳ WSL2 configuration (`.wslconfig`) optimization (Week 2)
3. ⏳ Git and shell performance tuning (Week 3)
4. ⏳ Advanced kernel/I/O optimization (Week 4)

**Target Metrics**:
- Shell startup: < 300ms
- Git status: < 100ms (large repos)
- No perceptible lag in terminal operations

**Related Sessions**:
- Initial setup: `docs/sessions/2025-11-20-wsl2-ubuntu-installation.md`
- WezTerm cross-platform: `docs/sessions/2025-11-21-wezterm-wsl-cross-platform-fixes.md`
- Clipboard integration: `docs/sessions/2025-11-23-wsl2-clipboard-integration.md`

### Important WSL2 Paths
- **Windows clipboard**: `/mnt/c/Windows/system32/clip.exe`
- **Windows home**: `/mnt/c/Users/<username>/`
- **WSL home**: `/home/rpmessner/` (use this for projects - faster!)
- **WSL config**: `/etc/wsl.conf` (Linux side)
- **WSL config**: `C:\Users\<username>\.wslconfig` (Windows side, not created yet)

### WSL2 Best Practices
1. **Keep projects in Linux filesystem** (`/home/`) not Windows (`/mnt/c/`) for better performance
2. **Platform-specific code** should use conditional logic (see tmux.conf, wezterm.lua examples)
3. **Clipboard operations** go through Windows tools (`clip.exe`)
4. **Shell path detection** must handle both macOS and Ubuntu paths

## Key Dependencies

### Runtime Requirements

- **Node.js 24:** Managed via asdf (updated from 22 in Nov 2025)
- **Ruby 3:** For various tools and scripts
- **Lua:** For Neovim and Hammerspoon configs
- **pnpm:** Package manager for Node.js dependencies

### Essential Tools (Auto-installed)

- fd, ripgrep - use these to search for files instead of find and grep
- bat (cat replacement)
- git, lazygit (version control)
- tmux (terminal multiplexer)
- neovim (editor)

### macOS Specific

- Homebrew (package management)
- Cask applications (GUI apps)
- System preference automation

## Troubleshooting

### Common Issues

1. **Neovim LSP Issues:** Run `:Mason` to check tool installation
2. **Missing Dependencies:** Run `task sync` to update all tools
3. **Git Hook Failures:** Ensure conventional commit format
4. **Permission Issues:** Some setup steps require sudo access

### Debugging

- Use `task -v` for verbose output
- Check individual taskfiles for specific component issues
- Neovim: `:checkhealth` for diagnostic information
- Shell: Use `task shell:lint` for script validation

## Maintenance

### Regular Updates

- Daily: `git pull && task sync`
- Monthly: Review and update tool versions in `.tool-versions`
- As needed: Update Brewfile for new applications

### Version Management

- Repository uses semantic versioning
- Never read CHANGELOG.md it's auto generated and very large, just a waste of
  tokens to read
- Use git tags for specific version checkouts

## Notes for Claude Code

### Best Practices

1. **Respect existing patterns:** Follow the modular configuration approach
2. **Test changes:** Use `task ci:run` before committing
3. **Document changes:** Update this file when adding new major components
4. **Platform awareness:** Consider macOS/Linux compatibility
5. **Performance focus:** This setup prioritizes speed and efficiency

### Common Modifications

- Adding new tools: Update appropriate taskfile and `.tool-versions`
- Neovim plugins: Add to `config/nvim/lua/plugins/`
- Shell functions: Add to `config/zsh/functions.zsh`
- Git configuration: Modify `gitconfig` or related files
- Automation: Create/modify taskfiles for new workflows

This repository represents years of refinement for a productive development environment. Changes should enhance without disrupting the existing workflow patterns.

---

## Recent Work & Context for Future Sessions

### November 2025: WSL2 Integration & Optimization

**Major Achievements**:
1. ✅ **Clipboard Integration** (Nov 23, 2025)
   - Bidirectional Windows ↔ tmux clipboard working
   - Blazing fast paste performance (instant)
   - Session: `docs/sessions/2025-11-23-wsl2-clipboard-integration.md`

2. ✅ **WezTerm Cross-Platform** (Nov 21-22, 2025)
   - Auto-detection of WSL distributions
   - Platform-specific keybindings (Ctrl on Windows, Cmd on macOS)
   - Font rendering optimization (OpenGL backend on Windows)
   - Sessions: Multiple sessions in `docs/sessions/2025-11-21-*.md` and `2025-11-22-*.md`

3. ✅ **Unified Window Management** (Nov 22, 2025)
   - Consistent keybindings across vim, tmux, WezTerm
   - Navigate (hjkl), Swap (HJKL), Resize (Ctrl+hjkl), Zoom (z)
   - Fully documented in README.md

4. ✅ **Tmux Leader Change** (Nov 22, 2025)
   - Changed from `Ctrl+Z` to `Ctrl+S` (prevents accidental suspend)
   - Added secondary prefix `Ctrl+Z` for compatibility
   - Session: `docs/sessions/2025-11-22-tmux-leader-key-change.md`

**Active Development Areas**:
- 📋 **WSL2 Performance Optimization**: See `docs/wsl2-performance-roadmap.md`
  - Next: Establish performance baseline (Week 1)
  - Then: `.wslconfig` tuning, git optimization, shell startup

**Platform Focus Shift**:
- **Previous**: Primarily macOS
- **Current**: Windows 11 + WSL2 (Ubuntu 24.04) is primary platform
- **Future**: Maintain cross-platform compatibility but optimize for WSL2

### Key Files to Check for Context

**Recent Sessions** (Nov 20-23, 2025):
- `docs/sessions/2025-11-23-wsl2-clipboard-integration.md` - Clipboard work
- `docs/sessions/2025-11-22-tmux-leader-key-change.md` - Tmux prefix change
- `docs/sessions/2025-11-22-tmux-smart-pane-navigation-fix.md` - Navigation logic
- `docs/sessions/2025-11-21-wezterm-wsl-cross-platform-fixes.md` - WezTerm setup
- `docs/sessions/2025-11-20-wsl2-ubuntu-installation.md` - Initial WSL2 setup

**Roadmaps & Planning**:
- `docs/ROADMAP.md` - Main project roadmap (comprehensive, 1000+ lines)
- `docs/wsl2-performance-roadmap.md` - WSL2-specific performance plan

**Testing & Documentation**:
- `docs/clipboard-integration-test.md` - Clipboard testing guide

### Quick Context Lookups

**Question**: "How does clipboard integration work?"
**Answer**: Check `docs/sessions/2025-11-23-wsl2-clipboard-integration.md` (complete implementation details)

**Question**: "What are the keybindings?"
**Answer**: Check README.md for unified window management, or specific config files (tmux.conf, wezterm.lua)

**Question**: "What performance optimizations are planned?"
**Answer**: Check `docs/wsl2-performance-roadmap.md` (4-week plan with priorities)

**Question**: "Platform detection patterns?"
**Answer**: See "WSL2-Specific Context" section above for detection methods used throughout repo
