# fzf-tab SSH Completion Fix for WSL2

**Date:** 2025-11-22
**Status:** Complete
**Related:** 2025-11-20-wsl2-ubuntu-installation.md

## Summary

Fixed SSH hostname tab completion issues in zsh with fzf-tab on WSL2 Ubuntu. The problems manifested as:
1. SSH hosts from `~/.ssh/config` not appearing in the tab completion list
2. Extra escape characters (`$'\k`) appearing at the prompt during completion
3. Backslash characters appearing after selecting a completion

Root causes were CRLF line endings in the SSH config file (common in WSL2) and missing SSH host registration with zsh's completion system.

## Problem 1: SSH Hosts Not Showing in Completion List

### Issue

When typing `ssh <TAB>`, the fzf-tab completion window appeared but was empty. SSH hosts defined in `~/.ssh/config` (like `my_mac` and `work_mac`) were not being suggested.

### Root Cause

Zsh's completion system wasn't aware of the SSH hosts. While zsh has default SSH completion functions (`_ssh`), they weren't being populated with the hosts from `~/.ssh/config`. The fzf-tab plugin relies on zsh's underlying completion system—if hosts aren't registered there, they won't appear in fzf-tab's list.

### Investigation Steps

```bash
# Verified SSH config was readable
cat ~/.ssh/config

# Checked if hosts could be parsed manually
grep "^Host " ~/.ssh/config | grep -v "*" | awk '{print $2}'
# Output: my_mac, work_mac (confirmed hosts were present)

# Tested if completion system had hosts registered
zsh -c 'source ~/.zshrc && zstyle -a ":completion:*:ssh:*" hosts _hosts && echo $_hosts'
# Output: (empty) - hosts not registered
```

This revealed that while the SSH config file existed and was readable, the hosts weren't being registered with zsh's completion system via `zstyle`.

## Problem 2: Escape Characters `$'\k` Appearing at Prompt

### Issue

During tab completion, the literal characters `$'\k` would appear at the end of the prompt.

### Root Cause

This was caused by a **keybinding conflict** between:
1. **Zsh keybinding:** `bindkey "^K" kill-line` in `config/zsh/keybindings.zsh:6`
2. **fzf navigation:** fzf internally uses Ctrl+K to move up in lists

When fzf-tab launched fzf for completion, Ctrl+K keypresses (or escape sequences containing `\k`) were being mishandled, causing the literal representation to leak into the prompt instead of being processed correctly.

### Investigation Steps

```bash
# Checked for keybinding conflicts
grep -r "bindkey.*K" config/zsh/
# Found: bindkey "^K" kill-line

# Verified fzf-tab was the completion plugin
grep "fzf-tab" zinitrc
# Output: zinit light Aloxaf/fzf-tab (line 36)

# Checked fzf-tab default keybindings
cat ~/.local/share/zinit/plugins/Aloxaf---fzf-tab/README.md
# Confirmed Ctrl+K not explicitly mentioned, but fzf uses it for navigation
```

The conflict occurred because both zsh and fzf wanted to handle Ctrl+K, resulting in escape sequence pollution.

## Problem 3: Backslash Appearing After Selection

### Issue

When selecting a hostname from the fzf-tab list, a backslash (`\`) would appear after the hostname in the prompt. For example, selecting `my_mac` would result in `ssh my_mac\` or `ssh my\_mac`.

### Root Cause

The `~/.ssh/config` file had **CRLF (Windows-style) line endings** instead of Unix LF endings. This is extremely common in WSL2 when files are created or edited using Windows applications (VSCode, Notepad++, etc.).

When the hostname parsing read the file, carriage return characters (`\r` or `^M`) were included as part of the hostname. During completion, these were being escaped as visible backslashes.

### Investigation Steps

```bash
# Checked file encoding
file ~/.ssh/config
# Output: ASCII text, with CRLF line terminators

# Verified hosts had carriage returns
zsh -c 'source ~/.zshrc && zstyle -L | grep "ssh.*hosts"'
# Output: zstyle ':completion:*:ssh:*' hosts $'my_mac\C-M' $'work_mac\C-M'
# The \C-M is the carriage return character
```

The CRLF line endings caused `\r` characters to be appended to hostnames, which were then being displayed as backslashes during completion insertion.

## Solution

Created a comprehensive fzf-tab configuration file to solve all three problems.

### File: `config/zsh/fzf-tab.zsh`

```zsh
# fzf-tab configuration
# =====================

# Disable Ctrl+K in fzf to avoid conflict with zsh keybinding
# Use Ctrl+P for up navigation instead (already bound in keybindings.zsh)
zstyle ':fzf-tab:*' fzf-bindings 'ctrl-k:ignore'

# Configure fzf-tab to show more context
zstyle ':fzf-tab:*' fzf-min-height 15

# Parse SSH hosts from ~/.ssh/config and set them for completion
# This extracts all "Host" entries (excluding wildcards)
if [[ -r ~/.ssh/config ]]; then
  h=()
  # Read file, filter Host lines, remove "Host " prefix, exclude wildcards
  # Strip both leading/trailing whitespace and carriage returns (for CRLF files)
  h=(${${${${(@M)${(f)"$(<~/.ssh/config)"}:#Host *}#Host }:#*[*?]*}//$'\r'/})
  # Trim any remaining whitespace
  h=(${h//[[:space:]]##/ })
  h=(${h// /})
  zstyle ':completion:*:ssh:*' hosts $h
  zstyle ':completion:*:scp:*' hosts $h
  zstyle ':completion:*:sftp:*' hosts $h
fi

# Enable prefix matching for better SSH host completion
zstyle ':completion:*:ssh:*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:ssh:*' group-name ''

# Preview for SSH hosts (optional - shows the config entry)
zstyle ':fzf-tab:complete:ssh:*' fzf-preview 'echo "SSH Config Entry:" && grep -A 3 "^Host $word" ~/.ssh/config 2>/dev/null'
```

### Key Features

1. **Ctrl+K Conflict Resolution** (line 6)
   - Disables Ctrl+K in fzf with `fzf-bindings 'ctrl-k:ignore'`
   - Prevents keybinding conflict with zsh's `kill-line`
   - Users can still navigate with Ctrl+P/N (already configured) or arrow keys

2. **SSH Host Parsing** (lines 13-24)
   - Reads `~/.ssh/config` at shell startup
   - Extracts all `Host` entries (excluding wildcards like `Host *`)
   - **Strips carriage returns** (`//$'\r'/`) to handle CRLF files
   - Trims whitespace to ensure clean hostnames
   - Registers hosts with completion system via `zstyle` for ssh, scp, and sftp

3. **CRLF Handling** (line 17)
   - Uses parameter expansion `//$'\r'/` to remove all `\r` characters
   - Makes configuration resilient to CRLF files common in WSL2
   - Prevents backslash escaping during completion insertion

4. **Preview Window** (line 30)
   - Shows the corresponding SSH config entry when navigating hosts
   - Helps users remember which host is which (especially with many hosts)

### Additional Fix: Convert SSH Config Line Endings

```bash
# Convert CRLF to LF
sed -i 's/\r$//' ~/.ssh/config

# Clear stale completion cache
rm -f ~/.zcompdump*
```

The file conversion ensures the SSH config uses Unix line endings going forward.

## How the Parser Works

The hostname parsing uses zsh's powerful parameter expansion:

```zsh
h=(${${${${(@M)${(f)"$(<~/.ssh/config)"}:#Host *}#Host }:#*[*?]*}//$'\r'/})
```

Breaking this down from inside-out:

1. `$(<~/.ssh/config)` - Read file contents
2. `${(f)"..."}` - Split on newlines into array
3. `${(@M)...:#Host *}` - Filter lines matching "Host *" pattern
4. `${...#Host }` - Remove "Host " prefix from each line
5. `${...:#*[*?]*}` - Exclude entries with wildcards (* or ?)
6. `${...//$'\r'/}` - Remove all carriage return characters

This results in a clean array of hostnames like `(my_mac work_mac)`.

## Benefits

1. **SSH hosts now appear in completion** - All hosts from `~/.ssh/config` show up in fzf-tab
2. **No more escape characters** - Ctrl+K conflict resolved
3. **No more backslashes** - CRLF handling prevents escape character pollution
4. **Resilient to WSL2 quirks** - Handles CRLF files automatically
5. **Works for scp/sftp too** - Hosts registered for all SSH-related commands
6. **Preview window** - Shows SSH config context during selection
7. **Automatic loading** - File sourced by `zshrc:28-30` loop that loads all `config/zsh/*.zsh` files

## Tab Completion Plugin: fzf-tab

The tab completion list plugin is **fzf-tab** by Aloxaf (loaded in `zinitrc:36`):

```zsh
# Replace zsh's default completion selection menu with fzf!
zinit light Aloxaf/fzf-tab
```

This plugin replaces zsh's default completion menu with fzf's fuzzy finder interface, providing:
- Fuzzy search in completion results
- Preview windows
- Customizable keybindings
- Better UX for large completion lists

## Testing Results

All issues resolved:
- ✅ SSH hosts (`my_mac`, `work_mac`) appear in fzf-tab completion list
- ✅ No `$'\k` escape characters during completion
- ✅ No backslashes after selecting completions
- ✅ Preview window shows SSH config entry
- ✅ Works for ssh, scp, and sftp commands
- ✅ Ctrl+K conflict eliminated (can still use Ctrl+P/N or arrows)
- ✅ Resilient to CRLF files (tested by recreating the issue)

### Verification Commands

```bash
# Reload shell
source ~/.zshrc

# Test host parsing
zsh -c 'source ~/.zshrc && zstyle -a ":completion:*:ssh:*" hosts _hosts && printf "Host: [%s]\n" "${_hosts[@]}"'
# Output:
# Host: [my_mac]
# Host: [work_mac]

# Verify no carriage returns
zsh -c 'source ~/.zshrc && zstyle -L | grep "completion.*ssh.*hosts"'
# Output: zstyle ':completion:*:ssh:*' hosts my_mac work_mac
# (clean, no \C-M characters)

# Test completion
ssh <TAB>
# fzf-tab window appears with both hosts listed

# Test file line endings
file ~/.ssh/config
# Output: ASCII text (no "with CRLF")
```

## Files Modified

1. **`config/zsh/fzf-tab.zsh`** (new) - fzf-tab configuration with SSH host parsing and CRLF handling
2. **`~/.ssh/config`** - Converted from CRLF to LF line endings
3. **`~/.zcompdump*`** - Deleted to clear stale completion cache

## Key Decisions

**Created dedicated fzf-tab config:** Rather than adding SSH host parsing to `config/zsh/completions.zsh`, created a separate `fzf-tab.zsh` file for all fzf-tab-specific settings. This keeps concerns separated and makes it clear which settings are for fzf-tab vs general completion.

**Disabled Ctrl+K instead of rebinding:** Rather than trying to rebind Ctrl+K in either fzf or zsh, simply disabled it in fzf. Users can navigate with Ctrl+P/N (already configured in `keybindings.zsh`) or arrow keys. This is simpler and less likely to cause future conflicts.

**Parse hosts at shell startup:** Rather than creating a custom completion function, parse hosts once at shell startup and register them via `zstyle`. This is more efficient (one-time parse) and integrates cleanly with zsh's existing completion system.

**Handle CRLF in parser:** Rather than just converting the file once, added CRLF stripping to the parser itself. This makes the configuration resilient to future edits that might reintroduce CRLF (e.g., editing from Windows).

**Fixed the source file too:** While the parser handles CRLF, we also converted `~/.ssh/config` to LF endings. This ensures SSH itself doesn't have issues with the file (some SSH implementations are sensitive to line endings).

**Added preview window:** Included a preview window showing the SSH config entry. This is optional but helpful when you have many hosts and want to see IP addresses, usernames, or other config details before connecting.

**Register for scp/sftp too:** While the issue was reported for SSH, also registered hosts for scp and sftp completion. These commands use the same SSH config, so users expect the same completion behavior.

## Lessons Learned

1. **WSL2 and CRLF:** Files created or edited on the Windows side will often have CRLF line endings. Any shell parsing in WSL2 should defensively strip `\r` characters.

2. **zsh parameter expansion is powerful:** The hostname parsing uses nested parameter expansions to read, filter, and clean the file in one expression. While dense, this is more efficient than multiple grep/sed/awk pipes.

3. **Completion systems need explicit registration:** Just because a file exists and is readable doesn't mean completion systems know about it. SSH hosts must be explicitly registered via `zstyle` for zsh completion to find them.

4. **fzf-tab relies on zsh completion:** fzf-tab is a presentation layer over zsh's completion system. If hosts aren't in the underlying completion system, fzf-tab won't show them. Fix the root completion, not fzf-tab itself.

5. **Keybinding conflicts can be subtle:** The Ctrl+K conflict manifested as escape sequences in the prompt rather than obvious errors. When debugging weird characters during completion, check for keybinding conflicts between the shell and completion tools.

6. **File command is invaluable:** `file <path>` immediately reveals CRLF vs LF line endings. This should be the first debugging step for any WSL2 file parsing issues.

7. **Clear completion cache after changes:** The `~/.zcompdump*` files cache completion definitions. After changing completion configuration, delete these files (or run `compinit` without `-C`) to ensure changes take effect.

8. **Test with fresh shell:** When debugging zsh issues, always test with a fresh shell (`exec zsh` or new terminal) to ensure all startup files are re-sourced. Changes to `config/zsh/*.zsh` won't apply to existing shells.

## Common WSL2 CRLF Issues

CRLF line endings are a frequent source of problems in WSL2:

**When files get CRLF:**
- Cloning repos with `core.autocrlf=true` on Windows
- Editing WSL files with Windows editors (VSCode, Notepad++)
- Copy/pasting from Windows applications
- Creating files in `/mnt/c/` and moving them

**Preventive measures:**
```bash
# Configure git to not convert line endings
git config --global core.autocrlf input

# Configure VSCode to use LF
# settings.json:
"files.eol": "\n"

# Convert existing files
find . -type f -name "*.zsh" -exec dos2unix {} \;
# or
find . -type f -name "*.zsh" -exec sed -i 's/\r$//' {} \;
```

**Detection:**
```bash
file <filename>  # Shows "with CRLF line terminators" if present
cat -A <filename>  # Shows ^M at line ends
od -c <filename> | grep -A 1 "\\r"  # Shows \r characters
```

## Alternative Navigation Keys in fzf-tab

Since Ctrl+K is now disabled in fzf, use these for navigation:

- **Ctrl+P / Ctrl+N** - Move up/down (configured in `keybindings.zsh`)
- **Up / Down arrows** - Move up/down
- **Ctrl+Space** - Select multiple items
- **F1 / F2** - Switch between completion groups
- **/** - Trigger continuous completion (for deep paths)
- **Enter** - Accept selection
- **Tab** - Continue completion

## Related Documentation

- [fzf-tab GitHub](https://github.com/Aloxaf/fzf-tab) - Main plugin repository
- [fzf-tab Configuration Wiki](https://github.com/Aloxaf/fzf-tab/wiki/Configuration) - Configuration options
- [fzf-tab issue #503](https://github.com/Aloxaf/fzf-tab/issues/503) - Similar backslash escaping issue with carapace

## Related Sessions

- 2025-11-20-wsl2-ubuntu-installation.md - Initial WSL2 setup
- Future: Full cross-platform testing of all completion systems

## Commands Reference

### Reload zsh configuration
```bash
source ~/.zshrc
# or
exec zsh
```

### Test SSH completion
```bash
# Should show fzf-tab window with hosts
ssh <TAB>
scp <TAB>
sftp <TAB>
```

### Check SSH config line endings
```bash
file ~/.ssh/config
# Good: ASCII text
# Bad: ASCII text, with CRLF line terminators
```

### Convert CRLF to LF
```bash
# Using sed (always available)
sed -i 's/\r$//' ~/.ssh/config

# Using dos2unix (if installed)
dos2unix ~/.ssh/config
```

### Clear completion cache
```bash
rm -f ~/.zcompdump*
# Completion cache will be regenerated on next shell startup
```

### Verify hosts are registered
```bash
zsh -c 'source ~/.zshrc && zstyle -a ":completion:*:ssh:*" hosts _hosts && echo "Hosts: ${_hosts[@]}"'
```

### Debug completion
```bash
# Enable completion debugging
zstyle ':completion:*' verbose yes

# See what completion system is doing
ssh <TAB>
# Then check output

# Disable debugging
zstyle -d ':completion:*' verbose
```

### Check for CRLF in any file
```bash
# Method 1: file command
file <filename>

# Method 2: cat with visible characters
cat -A <filename> | grep '\^M$'

# Method 3: od (octal dump)
od -c <filename> | grep '\\r'

# Method 4: grep (will show lines with CRLF)
grep -U $'\r' <filename>
```

### Bulk convert files to LF
```bash
# All zsh files
find config/zsh -name "*.zsh" -exec sed -i 's/\r$//' {} \;

# All shell scripts
find . -name "*.sh" -exec sed -i 's/\r$//' {} \;

# Entire directory (be careful!)
find . -type f -exec sed -i 's/\r$//' {} \;
```
