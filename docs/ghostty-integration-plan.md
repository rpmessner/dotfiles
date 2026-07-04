# Ghostty Integration Plan (Parked)

**Status:** Parked / not started — 2026-06-15
**Goal:** Make Ghostty a first-class shell host *alongside* WezTerm (coexist, not replace), driven by the same TokyoNight + FiraCode look and the unified window/pane keybindings used across vim/tmux/WezTerm.

## Context

WezTerm is the current GUI host on both daily platforms: native Windows (driving WSL2) and macOS. It works fine today — this is a "great performance, worth a look" exploration, not a problem fix. Ghostty is attractive for its rendering speed. Upstream `dkarter/dotfiles` has a `config/ghostty/config` to follow as a reference.

### Key findings from investigation

- **Ghostty does have native tabs + splits** (split/navigate/resize/zoom/equalize) and a dropdown "quick terminal." It intentionally *lacks* WezTerm's heavier multiplexer layer (persistent sessions, "domains," remote/SSH multiplexing). For this user's usage (mostly tabs, rare splits) there is **no fundamental impedance mismatch** — the WezTerm tab/split bindings can be mirrored natively in Ghostty.
- **dkarter's approach delegates everything to tmux** (keybinds send tmux-prefix escape sequences, `\x1a` = `Ctrl+Z`). That's a stylistic choice, not a Ghostty limitation. Since this user leans on *native* tabs, the recommendation is to **mirror WezTerm's native bindings** rather than route through tmux.
- **Platform is the catch — but evolving:** Ghostty has **no *official* Windows build**. Options on the Windows/WSL2 machine:
  - **WSLg** — run Ghostty as a Linux GUI app inside WSL2. Adds an X/Wayland layer that may erode the perf win; awkward launch story.
  - **Native Windows community fork** — a cluster of forks now ship native Win32 builds (no WSL/WSLg), all built on adilahmeddev's `windows-apprt` (~34k LOC):
    - [InsipidPoint/ghostty-windows](https://github.com/InsipidPoint/ghostty-windows) — Win32 + OpenGL + ConPTY, 100% apprt coverage, "daily-use ready"
    - [Winghostty](https://winghostty.com/) — Win10/11 x64+ARM64, native tabs, DPI, dark titlebar, IME
    - [Thr45hx/ghostty-windows](https://github.com/Thr45hx/ghostty-windows) — native x64, GPU-accel, "stable" (Mar 2026)
    - [deblasis/wintty](https://github.com/deblasis/wintty) — WinUI3 + DX12, ~88% MVP, in progress
    A native fork could host WSL2 the same way WezTerm.exe does (`wsl.exe` launch cmd), sidestepping WSLg. Trade-off: trusting an unofficial fork as a daily driver.
  - **Therefore:** **macOS** → clean win (official Homebrew cask). **Windows/WSL2** → either keep WezTerm, try WSLg (experimental), or evaluate a native fork (experimental, unofficial).

- **Zig / apprt architecture:** Ghostty's *core* (emulation + GPU rendering) is platform-agnostic Zig and already compiles for Windows. The gap is the *apprt* (application runtime: windowing/tabs/input/clipboard), which is hand-written per platform — SwiftUI/AppKit (macOS), GTK4+libadwaita (Linux), and **no upstream Windows apprt**. Maintainers call Windows "implementation effort, not a fundamental limitation"; it's on the roadmap but unshipped, and the Linux apprt is mid-refactor ([`gtk-ng`](https://github.com/ghostty-org/ghostty/pull/7961)).

- **Symlink wiring is free:** `taskfiles/dotfiles.yml` `symlink` task already loops every `config/*` folder into `~/.config`, so a new `config/ghostty/` directory is picked up automatically. No new symlink task needed.

## Recommended approach (when un-parked)

Coexist with WezTerm. Target **macOS first** as the supported path; treat **WSL2/WSLg as experimental** and document caveats.

### 1. `config/ghostty/config` (new)
Mirror `config/wezterm/wezterm.lua` look + bindings:
- **Appearance:** `theme = TokyoNight`, `font-family = FiraCode Nerd Font` (fallbacks JetBrains Mono / Cascadia Code), `font-size` (~11 to match WezTerm; dkarter uses 17), window padding, ligatures on. Opacity/blur optional.
- **macOS:** `macos-titlebar-style = tabs`.
- **Shell integration:** Ghostty auto-injects shell integration; ensure zsh plays nice (cursor, OSC 133 command-finish notifications).
- **Copy/paste:** match WezTerm — `cmd/ctrl+shift+c/v`, `shift+insert` paste.
- **Unified keybindings (native, sequenced leader):** use Ghostty's `ctrl+space>KEY` sequence syntax to reproduce the WezTerm leader bindings:
  - navigate `h/j/k/l` → `goto_split:left/down/up/right`
  - resize `ctrl+h/j/k/l` → `resize_split:...`
  - split `s`/`v` → `new_split:down`/`new_split:right`
  - zoom `z` → `toggle_split_zoom`, equalize `=` → `equalize_splits`
  - tabs: `c` new tab, `Tab` last tab, plus `cmd/ctrl+digit` direct tab access
  - copy mode `[` (Ghostty lacks WezTerm copy-mode; map to scrollback/selection equivalent or note the gap)
- **Quick terminal:** `global:cmd+'` → `toggle_quick_terminal` (macOS global hotkey).
- **`config-file = ?config.local`** for machine-specific overrides.
- Skip dkarter's `custom-shader` cursor glsl (extra dependency, optional eye-candy).

### 2. `config/ghostty/config.local` — gitignored example only (machine-specific)

### 3. Install wiring
- **macOS:** add `cask 'ghostty'` to `Brewfile` (near `cask 'wezterm'`, line ~7).
- **WSL2/Linux:** Ghostty isn't in standard apt repos. Either a `taskfiles/ghostty.yml` that installs via a community `.deb`/snap/build, or document manual install. Document the **WSLg launch story** (or native-fork choice) before committing to this path.
- No install task is wired into `install`/`sync` until the macOS path is validated.

### 4. Documentation
- Update `KEYBINDINGS.md` / `README.md` "Unified Window/Pane Management" to note Ghostty as a third host with its native-binding caveats.
- Update `CLAUDE.md` config-areas section to mention `config/ghostty/`.
- Add a `docs/sessions/` note when implemented.

## Open questions to resolve before implementing
1. On Windows/WSL2: scope to **macOS only**, try **WSLg** (benchmark vs WezTerm-on-Windows), or evaluate a **native fork** (e.g. InsipidPoint/Winghostty) as a `wsl.exe` host? Forks are unofficial — weigh maintenance/trust risk.
2. Native splits vs. tmux-delegated — confirmed leaning native; revisit if copy-mode/session gaps bite.
3. Font size parity (11) vs. dkarter's 17.

## Verification (when implemented)
- macOS: `brew install --cask ghostty`, `task sync`, confirm `~/.config/ghostty/config` symlink resolves, launch Ghostty, verify TokyoNight + FiraCode, tab/split/quick-terminal keybindings, copy/paste, and that zsh shell integration loads.
- WSL2 (if pursued): confirm a window launches via WSLg (or native fork) and informally compare input latency / scroll smoothness against WezTerm.
