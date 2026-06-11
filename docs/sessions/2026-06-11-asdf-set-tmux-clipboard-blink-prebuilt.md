# asdf 0.19 Migration, tmux macOS Clipboard, blink.cmp Prebuilt Binary

**Date**: 2026-06-11
**Platform**: macOS (secondary)

## Summary

Three independent fixes uncovered while running `task rust:install`:

1. All language `:install` taskfiles broke under asdf 0.19 because `asdf global` was removed in 0.16+. Migrated to `asdf set -u`.
2. tmux copy-mode `Enter` did nothing on macOS — only the WSL2 branch of the platform `if-shell` re-bound it after the global unbind.
3. blink.cmp threw "Incomplete build of the fuzzy matching library" because the config forced a source compile (`cargo build --release`), but `frizbee` requires **nightly** Rust that the asdf-installed stable toolchain (1.96.0) can't provide.

## Changes Made

### 1. asdf 0.16+ Migration: `asdf global` → `asdf set -u`

**Issue**: `task rust:install` failed at the `asdf global rust latest` step with `invalid command provided: global`. asdf 0.16 removed `global`/`local` in favor of `asdf set` (with `-u`/`--home` writing to `$HOME/.tool-versions`, the old `global` equivalent).

**Verified**: `asdf set -u rust latest` still resolves `latest` to the concrete installed version (1.96.0) and writes it to `~/.tool-versions`. No need to pre-resolve.

**Fix**: Replaced `asdf global <tool> latest` → `asdf set -u <tool> latest` across 8 taskfiles (10 occurrences):

- `taskfiles/rust.yml`
- `taskfiles/go.yml`
- `taskfiles/node.yml`
- `taskfiles/python.yml`
- `taskfiles/ruby.yml`
- `taskfiles/elixir.yml`
- `taskfiles/erlang.yml` (2 occurrences: erlang and rebar)
- `taskfiles/zig.yml` (2 occurrences: install + tools:install)

**Historical note**: The 2025-12-03 session went the *opposite* direction (`asdf set` → `asdf global`) because that was the correct syntax for asdf 0.15 and earlier. This session reverses that because the asdf upgrade to 0.19 changed the CLI again. Future asdf upgrades may shift this again — check the current version's help if `task <lang>:install` ever fails the same way.

### 2. tmux macOS Clipboard: `Enter` in Copy Mode

**Issue**: In tmux on macOS, `prefix [` → select with `v` → `Enter` did nothing. Mouse drag still copied (via tmux-yank's `pbcopy` mouse binding), so the clipboard backend itself was fine.

**Root cause**: `config/tmux/tmux.conf:205` globally unbinds `Enter` in copy-mode-vi. The platform `if-shell` at line 296 only re-bound `Enter` in the WSL2 branch (to `clip.exe`). macOS had no corresponding binding, so `Enter` stayed dead. Consistent with the Nov 2025 work focusing on WSL2 clipboard integration.

**Fix**: Added an `else` branch to the platform `if-shell` (tmux.conf:302-303), mirroring the WSL2 branch but using `pbcopy`:

```tmux
  if-shell "uname -r | grep -i microsoft" \
    "set -s set-clipboard off; \
     bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'cat | clip.exe'; \
     bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'cat | clip.exe'; \
     unbind-key -T copy-mode-vi MouseDragEnd1Pane; \
     unbind-key -T copy-mode MouseDragEnd1Pane" \
    "bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'pbcopy'; \
     bind-key -T copy-mode-vi y send-keys -X copy-pipe-and-cancel 'pbcopy'"
```

`y` is also bound here for symmetry; tmux-yank already provides `y` on macOS but explicit pairing keeps both keys consistent with the WSL branch.

Live-applied to the running server via `tmux source-file ~/.config/tmux/tmux.conf`.

### 3. blink.cmp Prebuilt Binary (no source build)

**Issue**: Opening Neovim showed:
```
blink.cmp  Incomplete build of the fuzzy matching library detected,
please re-run cargo build --release
```

**Root cause**: `config/nvim/lua/plugins/blink-cmp.lua` had both:
```lua
version = "1.*",                  -- prebuilt-binary path
build = "cargo build --release",  -- source-build path
```

The `build` line wins, forcing source compilation. The dependency `frizbee` uses `std::simd::SupportedLaneCount`, `std::simd::LaneCount`, and `#![feature(avx512_target_feature)]` — all **nightly-only** Rust features. The asdf stable 1.96.0 toolchain we just installed rejects them, leaving a half-built `target/` that triggered blink's "Incomplete build" check on the next nvim launch.

**Fix**: Removed the `build` line. With `version = "1.*"` and no build override, blink's default `fuzzy.prebuilt_binaries.download = true` kicks in and downloads the prebuilt `libblink_cmp_fuzzy.dylib` for the checked-out tag (v1.8.0) from the GitHub release.

Also cleared the stale `~/.local/share/nvim/lazy/blink.cmp/target/` directory so blink wouldn't detect the partial build.

**Verified**: Triggered the download headlessly with `nvim --headless "+Lazy! load blink.cmp" "+sleep 8" "+qa"`; resulting binary lands at `target/release/libblink_cmp_fuzzy.dylib` (3.1M, aarch64-apple-darwin).

**Trade-off**: This ties the fuzzy library to blink's release tags. If we ever switch to tracking `main`/nightly of blink itself, we'll need to both re-add the build step and install a nightly Rust toolchain (asdf-rust does support `nightly` as a version, but it's not currently set up).

## Files Modified

- `taskfiles/{rust,go,node,python,ruby,elixir,erlang,zig}.yml` — `asdf global` → `asdf set -u`
- `config/tmux/tmux.conf` — added macOS `else` branch to platform clipboard `if-shell`
- `config/nvim/lua/plugins/blink-cmp.lua` — removed `build = "cargo build --release"`

## Testing

```bash
# 1. asdf set works
task rust:install
asdf current rust   # → 1.96.0  /Users/ryanmessner/.tool-versions  true

# 2. tmux Enter copies on macOS
tmux source-file ~/.config/tmux/tmux.conf
tmux list-keys -T copy-mode-vi | grep Enter
# → bind-key -T copy-mode-vi Enter   send-keys -X copy-pipe-and-cancel pbcopy
# Manual: prefix [ → v → motion → Enter → pbpaste in another pane

# 3. blink downloads prebuilt
nvim --headless "+Lazy! load blink.cmp" "+sleep 8" "+qa"
ls -la ~/.local/share/nvim/lazy/blink.cmp/target/release/libblink_cmp_fuzzy.dylib
# → present (3.1M)
```

## References

- asdf 0.16 changelog: removal of `asdf global` / `asdf local` in favor of `asdf set`
- Prior asdf taskfile session (going the *opposite* direction under asdf 0.15): `docs/sessions/2025-12-03-zig-support-and-completions-fix.md`
- WSL2 clipboard origin of the platform `if-shell` block: `docs/sessions/2025-11-23-wsl2-clipboard-integration.md`
- blink.cmp v1.8.0 prebuilt assets: https://github.com/Saghen/blink.cmp/releases/tag/v1.8.0
