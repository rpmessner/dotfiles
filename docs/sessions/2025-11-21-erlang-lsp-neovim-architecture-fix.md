# Erlang LSP Installation Failure - Architecture Mismatch

**Date:** 2025-11-21
**Issue:** Erlang language server (erlangls) failing to install in Neovim via Mason
**Root Causes:** Missing rebar3 dependency + Treesitter parser architecture mismatch (x86_64 vs ARM64)

## Problem Description

When attempting to auto-install the Erlang language server through LazyVim/Mason, the installation failed with:
```
[mason-lspconfig.nvim] failed to install erlangls. Installation logs are available in :Mason and :MasonLog
```

Additionally, Neovim displayed treesitter errors on file open:
```
Failed to load parser for language 'markdown': uv_dlopen: dlopen(...parser/markdown.so, 0x0001):
tried: '.../parser/markdown.so' (mach-o file, but is an incompatible architecture
(have 'x86_64', need 'arm64e' or 'arm64'))
```

## Investigation Findings

### System Environment
- **Platform:** macOS (Apple Silicon, ARM64)
- **Erlang:** OTP 26 installed via asdf
- **Neovim:** Nightly build
- **LazyVim:** Auto-installation of LSP servers via Mason

### Root Causes Identified

#### 1. Missing rebar3 (Primary Issue for erlangls)
The Erlang language server requires `rebar3` (Erlang build tool) to compile during installation. While Erlang OTP 26 was installed via asdf, rebar3 was not available in the PATH.

**Evidence:**
```bash
$ which rebar3
rebar3 not found
```

**Why this matters:**
- Mason attempts to compile erlangls from source
- The build process requires rebar3 to compile Erlang code
- Without rebar3, the installation fails silently or with build errors

#### 2. Duplicate rebar Entry in .tool-versions
The `~/.tool-versions` file contained two conflicting rebar entries:
```
rebar 3.22.1
...
rebar 3.25.1
```

This caused asdf to not properly set the rebar3 binary in PATH, even though version 3.25.1 was already installed.

#### 3. Treesitter Parser Architecture Mismatch (Secondary Issue)
Neovim's treesitter parsers were compiled for x86_64 (Intel) architecture but the system is ARM64 (Apple Silicon).

**Evidence:**
```bash
$ file ~/.local/share/nvim/site/parser/markdown.so
...parser/markdown.so: (mach-o file, but is an incompatible architecture (have 'x86_64', need 'arm64e' or 'arm64'))
```

**Why this happened:**
- Likely from migrating from an Intel Mac or restoring from a backup
- Could also occur from building Neovim/parsers under Rosetta emulation
- Parsers in `~/.local/share/nvim/site/parser/` were old x86_64 binaries

## Solutions Applied

### Fix 1: Resolved rebar3 Duplicate Entries
**File: `~/.tool-versions`**

Removed the duplicate rebar entry, keeping only the latest version:
```diff
-rebar 3.22.1
 ruby 3.2.2
 rust 1.76.0
 tmux 3.4
 neovim nightly
 rebar 3.25.1
```

### Fix 2: Verified rebar3 Installation
```bash
$ rebar3 version
rebar 3.25.1 on Erlang/OTP 26 Erts 14.2.3
```

After fixing the `.tool-versions` file, rebar3 became available in the PATH through asdf's shim system.

### Fix 3: Removed x86_64 Treesitter Parsers
```bash
$ rm -rf ~/.local/share/nvim/site/parser/
```

This removes all old x86_64 compiled parsers. Neovim will automatically rebuild them for ARM64 on next startup.

**Note:** The parsers in `~/.local/share/nvim/lazy/nvim-treesitter/parser/` were already ARM64 and didn't need removal.

## Post-Fix Steps

### 1. Rebuild Treesitter Parsers
After removing old parsers, reopen Neovim and it will automatically detect missing parsers and rebuild them. Or manually run:
```vim
:TSInstall markdown
:TSInstall erlang
```

### 2. Install Erlang Language Server
With rebar3 now available, retry the erlangls installation:
```vim
:MasonInstall erlangls
```

Or wait for LazyVim to auto-install on opening an Erlang file.

## Verification Commands

### Check rebar3 is available:
```bash
which rebar3
rebar3 version
```

### Verify parser architecture:
```bash
file ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so | head -3
# Should show: Mach-O 64-bit bundle arm64
```

### Check Mason installation status:
```vim
:Mason
# Search for erlangls and verify it's installed
```

### Verify LSP is working:
Open an Erlang file (`.erl` or `.hrl`) and check:
```vim
:LspInfo
# Should show erlangls attached to the buffer
```

## Architecture Mismatch Context

### How This Happens

**Common Scenarios:**
1. **Migration from Intel Mac:**
   - Restoring from Time Machine backup
   - Copying dotfiles/config from Intel Mac to Apple Silicon Mac
   - Binary artifacts (compiled parsers, native modules) come with the backup

2. **Building Under Rosetta:**
   - Installing/building tools while terminal is running under Rosetta 2
   - Some old x86_64 binaries may persist even after switching to native ARM64

3. **Mixed Architecture Toolchains:**
   - Some tools installed via Homebrew x86_64 version
   - Others installed via ARM64 native version
   - Build processes can pick up wrong architecture compilers

### Prevention

To prevent architecture mismatches in the future:

1. **Always verify architecture when installing binary tools:**
   ```bash
   uname -m  # Should show: arm64
   file $(which nvim)  # Should include: arm64
   ```

2. **Clean rebuild after migration:**
   ```bash
   # Remove all compiled artifacts
   rm -rf ~/.local/share/nvim/site/parser/
   rm -rf ~/.local/share/nvim/lazy/*/build/

   # Reinstall/rebuild everything
   task sync
   ```

3. **Check Homebrew architecture:**
   ```bash
   brew config | grep CPU
   # Should show: CPU: arm-cpu-family
   ```

4. **asdf-managed tools:**
   - asdf compiles from source based on current architecture
   - Should naturally produce ARM64 binaries on Apple Silicon
   - But check if using pre-compiled binaries from plugins

## Related Cross-Platform Concerns

This session revealed potential issues for the cross-platform dotfiles effort:

### 1. Architecture-Specific Binaries
**Affected Components:**
- Neovim treesitter parsers (compiled `.so` files)
- Native Lua modules (like gitstatus)
- Rust-based tools (like blink-cmp, though currently disabled)
- Node native addons
- Ruby gems with C extensions

**Solution Considerations:**
- Don't version control compiled binaries
- Add `.gitignore` entries for parser directories
- Document rebuild steps in post-install
- Consider Task automation for "clean + rebuild"

### 2. Tool Availability Differences
**macOS vs Linux differences:**
- `brew` vs `apt`/`dnf`
- Some tools may have different package names
- Pre-compiled binaries may not exist for all platforms

**rebar3 Specifically:**
- asdf plugin available for cross-platform installation
- Should be in `.tool-versions` for consistency
- Already present in dotfiles, but wasn't properly configured

### 3. Build Tool Dependencies
**Erlang Development Stack:**
- Requires: Erlang + rebar3
- Currently in `.tool-versions`: ✓ erlang 26.2.3, ✓ rebar 3.25.1
- These should work consistently across platforms via asdf

**Potential issues:**
- System-level dependencies for compilation (gcc, make, etc.)
- Different dependency names on different OSes
- May need conditional Taskfile steps per platform

## Files Modified

### `~/.tool-versions`
- Removed duplicate `rebar 3.22.1` entry
- Kept `rebar 3.25.1` as the active version

### Directories Cleaned
- `~/.local/share/nvim/site/parser/` - Removed x86_64 parsers

## Future Considerations

### 1. Document Dependencies Better
The CLAUDE.md mentions "Essential Tools" but doesn't explicitly list rebar3 as required for Erlang development. Should add:

```markdown
### Language-Specific Tools (asdf managed)
- **Erlang + rebar3:** Required for Erlang/Elixir development and LSP
- **Node.js + pnpm:** JavaScript/TypeScript development
- **Ruby + bundler:** Ruby development
```

### 2. Post-Install Architecture Check
Could add to `task sync` or post-install:
```bash
# Verify we're on the expected architecture
expected_arch="arm64"  # or detect from uname -m
for parser in ~/.local/share/nvim/lazy/nvim-treesitter/parser/*.so; do
  arch=$(file "$parser" | grep -o 'arm64\|x86_64')
  if [[ "$arch" != "$expected_arch" ]]; then
    echo "Warning: $parser is $arch, expected $expected_arch"
  fi
done
```

### 3. Clean Install Task
Create a task for clean rebuild of architecture-specific artifacts:
```yaml
# taskfiles/neovim.yml
clean:
  desc: Clean architecture-specific Neovim artifacts
  cmds:
    - rm -rf ~/.local/share/nvim/site/parser/
    - rm -rf ~/.local/share/nvim/lazy/*/build/
    - echo "Cleaned. Restart Neovim to rebuild parsers."
```

### 4. Migration Guide
Add a migration guide to docs for:
- Intel Mac → Apple Silicon Mac
- macOS → Linux
- Steps to clean and rebuild architecture-specific components

### 5. .gitignore for Compiled Artifacts
Ensure compiled artifacts are ignored if any get added to dotfiles:
```gitignore
# Neovim
.local/share/nvim/site/parser/
.local/share/nvim/lazy/*/build/

# asdf compiled shims
.local/share/asdf/shims/
```

## Tags
`#erlang` `#neovim` `#mason` `#lsp` `#treesitter` `#architecture` `#arm64` `#x86_64` `#apple-silicon` `#rebar3` `#asdf` `#cross-platform`
