# Tmux Escape Sequences Issue - SSH Context

**Date:** 2025-11-21
**Issue:** Extra characters appearing in tmux sessions causing system ding
**Root Cause:** SSH session context + Powerlevel10k instant prompt + gitstatus initialization

## Problem Description

When running `tmux new`, extra characters like `]][[~~` were appearing in the newly opened shell, causing a system ding/bell sound. These are escape sequences that became visible instead of being interpreted correctly.

## Investigation Findings

### Initial Symptoms
- Visible escape sequences: `]][[~~` type characters
- System bell/ding sound on tmux new session creation
- Characters appeared at shell initialization

### Root Causes Identified

1. **SSH Context (Primary)**
   - Issue occurred when launching tmux from inside an SSH session
   - Terminal capabilities and environment variables differ between local Mac terminal and SSH session
   - Powerlevel10k instant prompt + SSH = escape sequence rendering issues

2. **Gitstatus Not Built (Secondary)**
   - Powerlevel10k's gitstatus daemon binary was missing
   - Binary should be at: `~/.local/share/zinit/plugins/romkatv---powerlevel10k/gitstatus/bin/gitstatusd`
   - Missing binary caused initialization errors during shell startup
   - Any output during P10k instant prompt initialization appears as visible escape sequences

3. **Stale Instant Prompt Cache (Tertiary)**
   - P10k caches instant prompt state in `~/.cache/p10k-instant-prompt-*.zsh`
   - Cache can contain error states from previous failed initializations

## Solutions Applied

### Fix 1: Built Gitstatus Binary
```bash
cd ~/.local/share/zinit/plugins/romkatv---powerlevel10k/gitstatus
./build -w
```

This compiles the gitstatusd binary for the current architecture (arm64 in this case).

### Fix 2: Created Required Symlinks
The gitstatus build places binaries in `usrbin/` but P10k looks for them in `bin/`:

```bash
cd ~/.local/share/zinit/plugins/romkatv---powerlevel10k/gitstatus
ln -sf usrbin bin
ln -sf gitstatusd bin/gitstatusd-darwin-arm64
```

### Fix 3: Cleared Instant Prompt Cache
```bash
rm ~/.cache/p10k-instant-prompt-*.zsh
```

### Fix 4: Proper SSH + Tmux Workflow (Best Practice)
**Don't:** Launch tmux from inside an SSH session
**Do:**
- Start tmux on your Mac directly (outside SSH)
- SSH into remote machines from within tmux sessions
- OR start tmux on the remote machine and attach to existing sessions

## Related Issue: Blink-cmp Encoding Problems

### Problem
During investigation, discovered that the shell locale was set to `C.UTF-8` (as a cross-platform fallback), which caused encoding issues with blink-cmp (Neovim completion plugin). Blink-cmp is a Rust-based binary and requires proper UTF-8 locale settings.

### Changes Made to Fix Blink-cmp
**File: `~/.dotfiles/zshrc` (lines 18-19)**
```diff
-export LANG="${LANG:-C.UTF-8}"
+export LANG="en_US.UTF-8"
+export LC_ALL="en_US.UTF-8"
```

**File: `~/.dotfiles/config/nvim/lua/plugins/blink-cmp.lua`**
```diff
  version = "1.*",
+ -- build from source for nightly compatibility
+ build = "cargo build --release",
```

### Why These Changes Matter
1. **`LANG="en_US.UTF-8"`** - Changed from fallback `C.UTF-8` to explicit `en_US.UTF-8`
   - `C.UTF-8` is a minimal locale that may not support all character encodings
   - Rust binaries like blink-cmp expect full UTF-8 locale support

2. **`LC_ALL="en_US.UTF-8"`** - Added to override all locale categories
   - Ensures consistent UTF-8 encoding across all locale categories (LC_CTYPE, LC_MESSAGES, etc.)
   - Prevents locale mixing that can cause encoding issues

3. **`build = "cargo build --release"`** - Build blink-cmp from source
   - Ensures binary is compiled for current architecture
   - Provides compatibility with Neovim nightly builds

### Multi-Machine Implications
This encoding change may need to be conditional for different environments:
- Systems without `en_US.UTF-8` installed will fail
- Some minimal Docker/CI environments only have `C.UTF-8`
- Remote SSH sessions may have different locale availability

**Future consideration:** Detect available locales and fall back gracefully:
```bash
# Pseudo-code for future implementation
if locale -a | grep -q en_US.utf8; then
  export LANG="en_US.UTF-8"
  export LC_ALL="en_US.UTF-8"
else
  export LANG="C.UTF-8"
  # Skip LC_ALL or use C.UTF-8
fi
```

## File Locations Reference

### Powerlevel10k Plugin
- Installation: `~/.local/share/zinit/plugins/romkatv---powerlevel10k/`
- Gitstatus: `~/.local/share/zinit/plugins/romkatv---powerlevel10k/gitstatus/`
- Binary location: `gitstatus/bin/gitstatusd` (symlink to `usrbin/gitstatusd`)
- Config: `~/.p10k.zsh` (if exists)

### Shell Configuration
- Main zshrc: `~/.dotfiles/zshrc` (symlinked from `~/.zshrc`)
- Zinit config: `~/.dotfiles/zinitrc` (symlinked from `~/.zinitrc`)
- P10k instant prompt: Lines 13-15 in zshrc
- P10k theme loading: `~/.dotfiles/zinitrc` lines 15-16

### Cache/State Files
- Instant prompt cache: `~/.cache/p10k-instant-prompt-${USER}.zsh`

## Terminal Environment Variables

Relevant environment variables that differ in SSH contexts:
- `$TERM` - Terminal type (was `tmux-256color` locally)
- `$TERM_PROGRAM` - Terminal emulator (was `tmux`)
- `$SSH_CLIENT`, `$SSH_CONNECTION` - Present only in SSH sessions
- `$LC_*`, `$LANG` - Locale settings may differ

## Future Work: Multi-Machine Installation Harmonization

### Context for Future Sessions
This session revealed that the dotfiles setup has machine-specific issues that should be addressed:

1. **Gitstatus Build Automation**
   - Should be part of initial setup/sync process
   - Detect if binary is missing and auto-rebuild
   - Handle different architectures (arm64, x86_64)

2. **SSH Context Detection**
   - Potentially disable P10k instant prompt when in SSH session
   - Add detection: `if [[ -n "$SSH_CLIENT" || -n "$SSH_TTY" ]]; then`
   - Alternative: Use lighter prompt theme for SSH sessions

3. **Platform-Specific Considerations**
   - macOS (arm64 vs x86_64)
   - Linux distributions
   - WSL environments
   - Different terminal emulators

4. **Locale/Encoding Handling**
   - Current setup hardcodes `en_US.UTF-8` for blink-cmp compatibility
   - This breaks on systems without `en_US.UTF-8` installed
   - Need to detect available locales and fall back gracefully
   - Consider making blink-cmp optional if locale isn't available

5. **Things to Collect from 3 Machines**
   - Architecture: `uname -m`
   - OS: `uname -s` and version
   - Terminal emulator: `$TERM_PROGRAM`
   - Shell: `$SHELL` and version
   - Primary usage pattern: Local? SSH? WSL?
   - Existing gitstatus binary status
   - P10k configuration existence
   - Zinit installation location
   - Any error messages during shell initialization
   - **Available locales:** `locale -a | grep -i utf`
   - **Current locale:** `locale` command output
   - **Neovim version:** `nvim --version` (for blink-cmp compatibility)

6. **Potential Unified Solutions**
   - Conditional P10k instant prompt (disable for SSH/slow environments)
   - Platform detection in setup scripts
   - Architecture-aware binary builds in Task automation
   - Cached binary builds (don't rebuild if already exists for arch)
   - Better error handling (silent failures for non-critical features)
   - **Locale detection and fallback** (check for `en_US.UTF-8`, fall back to `C.UTF-8`)
   - **Optional Rust-based plugins** (blink-cmp) when locale isn't suitable

### Questions to Answer from Multi-Machine Analysis
- Do all machines need the same prompt features?
- Should SSH sessions have a different shell configuration?
- Are there common missing dependencies across machines?
- Which features should be optional vs. required?
- What's the best way to handle architecture differences?
- **Which locales are available across all machines?**
- **Can we use en_US.UTF-8 everywhere, or do we need fallback logic?**
- **Is blink-cmp critical enough to require en_US.UTF-8, or should it be optional?**

## Commands for Verification

### Check if gitstatus is working:
```bash
~/.local/share/zinit/plugins/romkatv---powerlevel10k/gitstatus/bin/gitstatusd --version
```

### Check for instant prompt errors:
```bash
zsh -i -c exit 2>&1 | grep -i error
```

### Test in clean tmux session:
```bash
tmux new-session -d -s test
tmux send-keys -t test 'echo "test"; exit' C-m
tmux capture-pane -t test -p
tmux kill-session -t test
```

### Rebuild gitstatus if needed:
```bash
cd ~/.local/share/zinit/plugins/romkatv---powerlevel10k/gitstatus
./build -w
```

### Check locale settings:
```bash
# Check current locale
locale

# Check available UTF-8 locales
locale -a | grep -i utf

# Check if en_US.UTF-8 is available
locale -a | grep -i en_US.utf8

# Test if blink-cmp works with current locale
nvim --headless -c 'lua print(vim.inspect(require("blink-cmp")))' -c 'quit' 2>&1
```

## Related Documentation
- Powerlevel10k: https://github.com/romkatv/powerlevel10k
- Gitstatus: https://github.com/romkatv/gitstatus
- Zinit: https://github.com/zdharma-continuum/zinit
- Blink-cmp: https://github.com/Saghen/blink.cmp

## Tags
`#tmux` `#powerlevel10k` `#gitstatus` `#ssh` `#escape-sequences` `#shell-initialization` `#multi-machine` `#locale` `#encoding` `#blink-cmp` `#rust` `#neovim`
