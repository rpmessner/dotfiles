# Zig Language Support & Zsh Completions Fix

**Date**: 2025-12-03

## Summary

Added Zig language support to the dotfiles and fixed zsh task completions that weren't working due to `compinit -C` caching issues.

## Changes Made

### 1. Zig Language Support

**New file**: `taskfiles/zig.yml`
- `zig:install` - Installs Zig via asdf
- `zig:tools:install` - Installs ZLS (Zig Language Server) from GitHub releases
- `zig:tools:update` - Updates both Zig and ZLS
- `zig:tools:outdated` - Shows current versions
- `zig:clean` - Cleans build artifacts

**Modified**: `Taskfile.dist.yml`
- Added zig taskfile include

**Modified**: `config/nvim/lua/plugins/conform.lua`
- Added `zig = { "zigfmt" }` formatter entry

### 2. Fixed asdf Commands

**Issue**: All taskfiles were using `asdf set <tool> latest` which doesn't exist.

**Fix**: Changed to `asdf global <tool> latest` in:
- `taskfiles/rust.yml`
- `taskfiles/go.yml`
- `taskfiles/node.yml`
- `taskfiles/python.yml`
- `taskfiles/ruby.yml`
- `taskfiles/elixir.yml`
- `taskfiles/erlang.yml` (2 occurrences: erlang and rebar)
- `taskfiles/zig.yml`

### 3. Fixed Zsh Task Completions

**Problem**: `task z<TAB>` showed file completions instead of task names.

**Root cause**:
- `compinit -C` uses cached zcompdump without rescanning fpath
- The `_task` completion file existed in `~/.cache/zsh/completions/` but wasn't being loaded

**Fix 1**: `config/zsh/completions.zsh`
- Added explicit source of `~/.cache/zsh/completions/_task` after compinit
- This bypasses the autoload mechanism that wasn't working

**Fix 2**: `taskfiles/completions.yml`
- Changed `cache:reload` to use `zsh -ic` (interactive) so fpath is correct
- Added reminder to run `exec zsh` after regenerating completions

### 4. ZLS Installation

**Issue**: The asdf-zls plugin at `zigtools/asdf-zls` doesn't exist.

**Attempted fix**: Used `dochang/asdf-zls` but it has outdated download URLs (404 errors).

**Final solution**: Direct download from GitHub releases:
- Downloads from `https://github.com/zigtools/zls/releases/`
- Platform detection for Linux/macOS, x86_64/aarch64
- Installs to `~/.local/bin/zls`

## Testing

After changes:
```bash
# Reload shell
exec zsh

# Verify task completion works
cd ~/.dotfiles
task z<TAB>  # Should show zig:install, zig:tools:install, etc.

# Install Zig
task zig:install

# Install ZLS
task zig:tools:install

# Verify
zig version
zls --version
```

## Files Changed

| File | Change Type |
|------|-------------|
| `taskfiles/zig.yml` | Added |
| `Taskfile.dist.yml` | Modified |
| `config/nvim/lua/plugins/conform.lua` | Modified |
| `config/zsh/completions.zsh` | Modified |
| `taskfiles/completions.yml` | Modified |
| `taskfiles/rust.yml` | Modified |
| `taskfiles/go.yml` | Modified |
| `taskfiles/node.yml` | Modified |
| `taskfiles/python.yml` | Modified |
| `taskfiles/ruby.yml` | Modified |
| `taskfiles/elixir.yml` | Modified |
| `taskfiles/erlang.yml` | Modified |

## Notes

- The mix formatter in conform.lua was also updated to use file mode instead of stdin (prevents compilation output in buffer) - this may have been from a previous session
- ZLS version is hardcoded to 0.15.0 in the taskfile; update `ZLS_VERSION` variable when new versions are released
