# WezTerm WSL Cross-Platform Configuration Session

**Date**: November 21, 2025
**Platform**: Windows 11 + WSL2 (Ubuntu 24.04)
**Focus**: WezTerm configuration fixes and cross-platform support

---

## Overview

Major overhaul of WezTerm configuration to support cross-platform usage (Windows/WSL, macOS, Linux) with proper WSL integration, UI customization, and font rendering fixes.

---

## Issues Encountered & Fixes Applied

### 1. Git Branch Tracking Not Showing Ahead/Behind Status

**Issue**: `git status` didn't show how many commits ahead/behind origin/master.

**Root Cause**: Local `master` branch wasn't tracking `origin/master`.

**Solution**:
```bash
git branch --set-upstream-to=origin/master master
```

**Files Modified**: Git configuration (runtime)

**Status**: ✅ Fixed

---

### 2. GitHub CI: Lua Diagnostics Failing on `vim` Global

**Issue**: GitHub CI job `lua-diagnostics` reported "Undefined global `vim`" warnings for all Neovim config files.

**Root Cause**: CI used `lua-language-server --check` which doesn't know about Neovim's runtime environment where `vim` is a global.

**Solution**:
- Changed CI to use Neovim itself for Lua diagnostics (matching local taskfile approach)
- Added `neovim nightly` to `.tool-versions`
- Updated `.github/workflows/ci.yml` to install and use Neovim instead of lua-language-server

**Files Modified**:
- `.github/workflows/ci.yml`
- `.tool-versions`

**Commit**: `a89522e` - "fix(ci): use neovim for lua diagnostics instead of lua-language-server"

**Status**: ✅ Fixed

---

### 3. WezTerm Config Not Being Used (WSL/Windows Issue)

**Issue**: WezTerm running on Windows couldn't access config in WSL2 filesystem.

**Root Cause**:
- WezTerm runs as a native Windows application
- Config was symlinked in WSL (`~/.config/wezterm`) but WezTerm looks in Windows user directory
- Initial attempt used Unix symlinks which Windows applications can't read

**Solution**:
- Created automated symlinking task using PowerShell to create Windows-compatible symlinks
- New `taskfiles/wezterm.yml` with platform-aware sync
- Uses `\\wsl.localhost\Ubuntu-24.04\` path for Windows to access WSL files
- Integrated into `task install` and `task sync` workflows

**Files Created**:
- `taskfiles/wezterm.yml`

**Files Modified**:
- `Taskfile.dist.yml`
- `taskfiles/dotfiles.yml`

**Commit**: `60f3dc1` - "feat(wezterm): add cross-platform configuration sync"

**Status**: ✅ Fixed

---

### 4. WezTerm Launch Error: `/bin/zsh` Not Found

**Issue**: Error on WezTerm startup: `Process /bin/zsh -l in domain "local" didn't exit cleanly. Exited with code 1.`

**Root Cause**: WezTerm config hardcoded `/bin/zsh` as default shell, but WezTerm runs on Windows where this path doesn't exist.

**Solution**:
- Added platform detection (`wezterm.target_triple`)
- On Windows: Launch WSL by default with proper domain configuration
- On macOS/Linux: Use `/bin/zsh` directly

**Code Added**:
```lua
if is_windows then
  config.default_prog = { 'wsl.exe', '~' }
  config.wsl_domains = {
    {
      name = 'WSL:Ubuntu',
      distribution = 'Ubuntu-24.04',
      default_cwd = '~',
    },
  }
  config.default_domain = 'WSL:Ubuntu'
else
  config.default_prog = { '/bin/zsh', '-l' }
end
```

**Files Modified**:
- `config/wezterm/wezterm.lua`

**Status**: ✅ Fixed

---

### 5. Terminal Rendering Issues & Missing Colors

**Issue**:
- Character "echoes" building up to the right of cursor
- Error: "missing or unsuitable terminal: wezterm"
- P10k status bar colorless

**Root Cause**: `config.term = 'wezterm'` - most systems don't have `wezterm` terminfo entry.

**Solution**: Changed to `config.term = 'xterm-256color'` for universal compatibility.

**Files Modified**:
- `config/wezterm/wezterm.lua`

**Status**: ✅ Fixed

---

### 6. Platform-Specific Keybindings

**Issue**: All keybindings used `CMD` modifier (macOS-only), didn't work on Windows.

**Solution**:
- Added platform detection
- Set `mod = 'CTRL'` on Windows, `'CMD'` on macOS
- All keybindings now use platform-aware `mod` variable

**Example**:
```lua
local mod = is_macos and 'CMD' or 'CTRL'
local mod_shift = is_macos and 'CMD|SHIFT' or 'CTRL|SHIFT'
```

**Files Modified**:
- `config/wezterm/wezterm.lua`

**Status**: ✅ Fixed

---

### 7. Window Controls & Seamless UI

**Issue**: User wanted window controls (close/minimize/maximize) but with title bar matching terminal background.

**Solution**:
- Used `INTEGRATED_BUTTONS|RESIZE` decoration mode
- Buttons embedded in tab bar instead of separate title bar
- Custom tab bar colors matching Tokyo Night theme (`#1a1b26`)
- Tab bar moved to top for better button integration

**Configuration**:
```lua
config.window_decorations = 'INTEGRATED_BUTTONS|RESIZE'
config.window_frame = {
  active_titlebar_bg = '#1a1b26',   -- Tokyo Night background
  inactive_titlebar_bg = '#16161e',
}
```

**Files Modified**:
- `config/wezterm/wezterm.lua`

**Status**: ✅ Fixed

---

### 8. Font Clipping at Bottom of Characters

**Issue**: All characters (throughout terminal, not just tab bar) had bottom pixels clipped.

**Root Cause**: FiraCode Nerd Font has rendering issues on Windows, particularly with certain font sizes.

**Solutions Attempted**:
1. ❌ Increased `line_height` from 1.2 to 1.3 - didn't fix it
2. ❌ Changed tab bar font from Bold to Regular - helped tab bar only
3. ❌ Added border padding - caused red border around terminal
4. ✅ **Switched primary font to JetBrains Mono** - fixed the issue

**Final Font Configuration**:
```lua
config.font = wezterm.font_with_fallback {
  'JetBrains Mono',      -- Better Windows rendering
  'FiraCode Nerd Font',  -- Fallback
  'Cascadia Code',
  'Consolas',
}
```

**Files Modified**:
- `config/wezterm/wezterm.lua`

**Status**: ✅ Mostly Fixed (see Known Issues below)

---

## Summary of Configuration Changes

### New Features Added

1. **Cross-Platform Detection**
   - Detects Windows, macOS, Linux
   - Platform-specific shell launching
   - Platform-aware keybindings

2. **WSL Integration**
   - Automatic WSL domain configuration
   - Launches into WSL environment by default on Windows
   - Proper working directory handling

3. **Seamless UI Design**
   - Integrated window controls in tab bar
   - Tokyo Night color scheme throughout
   - Custom tab styling with hover effects
   - Battery and date in status bar

4. **Font Rendering Fixes**
   - Windows-specific freetype rendering settings
   - JetBrains Mono as primary font for better compatibility
   - Proper ligature support
   - Font size: 11pt with line_height: 1.2

5. **Enhanced Keybindings**
   - Config reload: `Ctrl+Shift+R` (Win) / `Cmd+Shift+R` (Mac)
   - Full screen: `Alt+Enter`
   - All standard bindings now platform-aware

6. **Improved Quick Select**
   - Windows path patterns (`C:\...`)
   - Unix path patterns
   - Git commit hashes
   - IP addresses
   - Hex colors

### Configuration File Structure

The new `wezterm.lua` is organized into clear sections:

```
- Platform Detection
- Appearance (colors, fonts, window)
- Performance Settings
- Shell Configuration (platform-specific)
- Platform-Aware Keybindings
- Copy Mode (vim-like)
- Mouse Bindings
- Hyperlinks & Quick Select
- Bell & Notifications
- Status & Tab Bar Customization
- Terminal Type
```

---

## Known Issues & Action Items

### 🔴 High Priority

#### 1. Font Clipping Reappears at Certain Font Sizes

**Issue**: When changing font size with `Ctrl+Shift++` or `Ctrl+Shift+-`, clipping reappears at specific sizes.

**Current Behavior**: JetBrains Mono at default size (11pt) renders correctly, but dynamic size changes can trigger clipping.

**Investigation Needed**:
- [ ] Test which font sizes trigger clipping
- [ ] Determine if it's related to cell height calculation
- [ ] Check if `line_height` needs to scale with font size
- [ ] Investigate if WezTerm's dynamic font sizing bypasses our `line_height` setting
- [ ] Consider if we need to disable font size keybindings or add a hook to reset

**Possible Solutions**:
- Override font size change action to also adjust `line_height` proportionally
- Set specific font size presets that don't clip
- Add event handler to recalculate cell metrics on font size change

**Files to Modify**:
- `config/wezterm/wezterm.lua`

**Priority**: High - Affects usability when zooming

---

### 🟡 Medium Priority

#### 2. Verify WSL Domain on Different Distro Names

**Issue**: Config hardcodes `Ubuntu-24.04` as WSL distribution name. May break on different Ubuntu versions or other distros.

**Action Items**:
- [ ] Test on different WSL distributions
- [ ] Add auto-detection of WSL distro name
- [ ] Consider making distribution configurable

**Files to Modify**:
- `config/wezterm/wezterm.lua`
- `taskfiles/wezterm.yml`

---

#### 3. Tab Bar Font Clipping (Minor)

**Status**: Mostly fixed but could be improved

**Issue**: Tab bar previously had clipping, fixed by changing from Bold to Regular weight.

**Possible Improvements**:
- [ ] Test if increasing tab bar font size to 11pt (match main font) still clips
- [ ] Experiment with tab bar line height if WezTerm adds that option
- [ ] Consider custom tab bar rendering for more control

**Files to Modify**:
- `config/wezterm/wezterm.lua`

---

### 🟢 Low Priority

#### 4. macOS-Specific Testing

**Status**: Changes made but not tested on macOS

**Action Items**:
- [ ] Test config on macOS
- [ ] Verify keybindings use `CMD` correctly
- [ ] Test window blur effect
- [ ] Verify native fullscreen mode setting

---

#### 5. Optimize Color Scheme Integration

**Current**: Manually set Tokyo Night colors

**Potential Improvement**:
- [ ] Extract colors from WezTerm's Tokyo Night scheme programmatically
- [ ] Add ability to switch colorschemes and have UI follow automatically
- [ ] Consider creating a theme system

**Files to Modify**:
- `config/wezterm/wezterm.lua`

---

#### 6. Documentation

**Action Items**:
- [ ] Add comment documenting font size clipping issue in config
- [ ] Document WSL setup requirements in README
- [ ] Add troubleshooting section for common Windows/WSL issues

---

## Testing Checklist

### ✅ Completed Tests (Windows/WSL)

- [x] Launch into WSL automatically
- [x] Tab creation (`Ctrl+T`)
- [x] Tab navigation (`Ctrl+Shift+[`, `Ctrl+Shift+]`)
- [x] Pane splitting (`Ctrl+D`, `Ctrl+Shift+D`)
- [x] Config reload (`Ctrl+Shift+R`)
- [x] Copy mode (`Ctrl+[`)
- [x] Colors rendering (Tokyo Night)
- [x] P10k status bar colors
- [x] Font rendering (no clipping at default size)
- [x] Integrated window controls
- [x] Tab bar colors matching terminal background

### ⏳ Pending Tests

- [ ] macOS compatibility
- [ ] Linux (non-WSL) compatibility
- [ ] Different WSL distributions
- [ ] Font size changes (fixing clipping issue)
- [ ] Quick select patterns (URLs, paths, hashes)
- [ ] Battery indicator (if on laptop)
- [ ] Full screen toggle (`Alt+Enter`)

---

## Files Changed

### Modified
- `.github/workflows/ci.yml` - Switched to Neovim for Lua diagnostics
- `.tool-versions` - Added `neovim nightly`
- `Taskfile.dist.yml` - Added wezterm taskfile include
- `taskfiles/dotfiles.yml` - Integrated wezterm:sync into install/sync tasks
- `config/wezterm/wezterm.lua` - Complete rewrite for cross-platform support

### Created
- `taskfiles/wezterm.yml` - WSL/Windows symlink automation
- `config/nvim/.luarc.json` - Lua LSP config (gitignored, local only)

### Git Status
```
M .claude/settings.local.json (local settings, not committed)
M config/wezterm/wezterm.lua (ready to commit)
```

---

## Recommendations

### For Next Session

1. **Font Size Clipping Fix** (High Priority)
   - Disable dynamic font sizing temporarily?
   - Or add event handler to maintain proper line height
   - Test on multiple font sizes to find safe ranges

2. **Test on macOS** (If available)
   - Verify cross-platform code works as expected
   - May reveal additional platform-specific issues

3. **Create Wezterm Documentation**
   - Document the font clipping workaround
   - Note which fonts work best on which platforms
   - Add WSL setup requirements

### Configuration Best Practices Going Forward

- **Font Testing**: Always test fonts on target platform before committing
- **Platform Detection**: Use `is_windows`, `is_macos`, `is_linux` for platform-specific settings
- **Symlink Validation**: WSL symlinks must use PowerShell on Windows (not `ln -s`)
- **Terminal Type**: Stick with `xterm-256color` for maximum compatibility
- **Keybindings**: Always use `mod` variable instead of hardcoding `CMD`/`CTRL`

---

## Additional Notes

### Why JetBrains Mono Over FiraCode?

FiraCode Nerd Font has known rendering issues on Windows:
- Cell height calculation inconsistencies
- Clipping at various font sizes
- Particularly bad with certain terminal emulators

JetBrains Mono:
- Designed specifically for IDEs and terminals
- Excellent cross-platform rendering
- Good ligature support
- Consistent metrics across sizes

If you prefer FiraCode's aesthetics, can try:
- Different FiraCode variants (Retina, Light, etc.)
- Specific size that renders well (needs testing)
- Use only on macOS/Linux

### WSL Integration Notes

The PowerShell symlink approach is necessary because:
1. Native Windows apps can't read Unix symlinks
2. WSL can create symlinks in Windows filesystem, but they're Unix-style
3. PowerShell's `New-Item -ItemType SymbolicLink` creates Windows-compatible symlinks
4. These symlinks work bidirectionally (WSL can read them too)

Path format: `\\wsl.localhost\Ubuntu-24.04\...` is the official way to access WSL from Windows.

---

## Related Sessions

- `2025-11-20-wsl2-ubuntu-installation.md` - Initial WSL setup and issues
- `2025-11-21-wezterm-consolidation-neovim-nightly-fixes.md` - Prior WezTerm work

---

## Conclusion

Major improvements to WezTerm configuration enabling true cross-platform usage. The config now automatically detects the platform and adjusts accordingly. Main remaining issue is font size clipping at certain sizes, which needs investigation.

**Next Steps**: Address font size clipping issue before committing final version.
