# WSL2 Clipboard Integration Testing

**Date**: 2025-11-23
**Platform**: WSL2 Ubuntu 24.04

## Changes Made

### 1. Fixed Default Shell Detection (config/tmux/tmux.conf:14-16)
- Changed from hardcoded `/opt/homebrew/bin/zsh` to auto-detection
- Now detects macOS vs Linux/WSL zsh path automatically

### 2. Added WSL2 Clipboard Integration (config/tmux/tmux.conf:212-220)
- Detects WSL2 environment via `uname -r | grep -i microsoft`
- Uses `clip.exe` for clipboard on WSL2
- Falls back to `pbcopy` for macOS
- Supports three copy methods:
  - `y` in copy mode (yank)
  - `Enter` in copy mode
  - Mouse drag selection

## Testing Instructions

### Prerequisites
1. You must be in a tmux session to test
2. Start tmux: `tmux` or `tmux new -s test`

### Step 1: Reload tmux Configuration
```bash
# Inside tmux, press: Ctrl+S then r
# You should see: "tmux.conf reloaded"
```

### Step 2: Test Copy from tmux to Windows

**Method 1: Keyboard Copy (y)**
1. Press `Ctrl+S` then `[` to enter copy mode
2. Navigate with vim keys (`hjkl`)
3. Press `v` to start visual selection
4. Select some text with `hjkl`
5. Press `y` to yank (copy)
6. Exit tmux copy mode (automatic after yank)
7. Open Notepad or any Windows app and paste (`Ctrl+V`)
8. ✅ You should see the text you copied

**Method 2: Keyboard Copy (Enter)**
1. Press `Ctrl+S` then `[` to enter copy mode
2. Press `v` to start visual selection
3. Select text
4. Press `Enter` to copy
5. Paste in Windows app
6. ✅ Verify text appears

**Method 3: Mouse Copy**
1. Click and drag to select text in tmux
2. Release mouse button (auto-copies)
3. Paste in Windows app
4. ✅ Verify text appears

### Step 3: Test Paste from Windows to tmux

**Note**: tmux-yank plugin should handle paste, but here's how to test:

1. Copy text from a Windows app (Notepad, browser, etc.)
2. In tmux, press `Ctrl+S` then `]` to paste from tmux buffer
   - This pastes from tmux's internal buffer, not Windows clipboard
3. Alternative: Right-click in WezTerm to paste from Windows clipboard
4. Alternative: Use `Shift+Insert` in WezTerm to paste from Windows

**Important**: Direct paste from Windows clipboard to tmux works via the terminal emulator (WezTerm), not tmux itself.

### Step 4: Verify Copy Mode Keybindings

All these should work in copy mode (`Ctrl+S` then `[`):
- `v` - Start visual selection
- `Ctrl+V` - Rectangle (block) visual selection
- `y` - Yank (copy) and exit
- `Enter` - Copy and exit
- `[` - Alternative to start selection
- `]` - Alternative to copy selection
- `h/j/k/l` - Navigate
- `w/b` - Word forward/backward
- `/` - Search forward
- `?` - Search backward
- `q` - Quit copy mode

## Expected Results

### ✅ Success Criteria
- [ ] tmux config reloads without errors
- [ ] Copy with `y` puts text in Windows clipboard
- [ ] Copy with `Enter` puts text in Windows clipboard
- [ ] Mouse drag selection puts text in Windows clipboard
- [ ] Can paste into Windows applications (Notepad, browser, etc.)
- [ ] Can paste from Windows into tmux (via terminal emulator)

### ❌ Troubleshooting

**Problem**: "tmux.conf reloaded" message doesn't appear
- Make sure you're inside a tmux session
- Try: `tmux source-file ~/.config/tmux/tmux.conf`

**Problem**: Copy doesn't work
- Verify you're on WSL2: `uname -r` should contain "microsoft"
- Verify clip.exe works: `echo test | clip.exe && echo success`
- Check tmux version: `tmux -V` (should be 3.0+)

**Problem**: Paste doesn't work
- Windows → tmux paste works via WezTerm, not tmux
- Use right-click or `Shift+Insert` in WezTerm
- `Ctrl+S` then `]` pastes from tmux buffer, not Windows clipboard

**Problem**: Mouse selection doesn't auto-copy
- Ensure mouse mode is enabled: `tmux show -g mouse` should show "mouse on"
- Try selecting text completely within one pane

## Implementation Details

### How It Works

1. **Platform Detection**: `if-shell "uname -r | grep -i microsoft"`
   - On WSL2: kernel version contains "Microsoft"
   - On native Linux: doesn't contain "Microsoft"
   - On macOS: uses different command

2. **Clipboard Tool**:
   - WSL2: `clip.exe` (Windows clipboard utility accessible from WSL)
   - macOS: `pbcopy` (via `reattach-to-user-namespace`)

3. **Copy Actions**:
   - `copy-pipe-and-cancel`: Copies to clipboard AND exits copy mode
   - Piped to clipboard tool automatically

### Files Modified
- `config/tmux/tmux.conf` (lines 14-16, 212-220)

## Next Steps

Once testing is complete:
1. Update ROADMAP.md to mark clipboard integration as complete
2. Document any issues found
3. Consider adding `win32yank` as a faster alternative to `clip.exe`

## Additional Resources

- tmux copy mode: `man tmux` (search for "copy-mode")
- WSL clipboard: https://devblogs.microsoft.com/commandline/copy-and-paste-arrives-for-linuxwsl-consoles/
