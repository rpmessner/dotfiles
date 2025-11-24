# ZSH/Vim Buffer Navigation Unification - Session Handoff

**Date:** 2025-11-24
**Status:** Partially Implemented (Alt+hjkl solution)
**Issue:** Need ergonomic vim-like navigation in zsh command line

---

## Problem Statement

User wants unified, vim-like navigation keybindings for the zsh command line that:
1. Use muscle memory from vim (hjkl movement)
2. Are ergonomic (not requiring awkward key combinations)
3. Don't break essential shell functionality
4. Work consistently across the environment

**Current Pain Point:**
- `Ctrl+F` was bound to `autosuggest-accept` but appeared broken (showed as `self-insert`)
- No vim-like character navigation in zsh (only emacs-style bindings)
- Alt key is unergonomic for frequent navigation

**Context:**
- User has unified window/pane management across vim, tmux, and WezTerm
- Heavy vim user with strong hjkl muscle memory
- Currently using emacs mode (`bindkey -e`) in zsh
- See `CLAUDE.md` "Unified Window/Pane Management" section for existing cross-tool keybinding strategy

---

## Current Implementation (Temporary)

**File:** `config/zsh/keybindings.zsh`

```zsh
# Vim-like navigation using Alt+ (doesn't conflict with essential Ctrl+ bindings)
bindkey '^[h' backward-char         # Alt+H - move left
bindkey '^[l' forward-char          # Alt+L - move right
bindkey '^[k' up-line-or-history    # Alt+K - move up
bindkey '^[j' down-line-or-history  # Alt+J - move down
bindkey '^[w' forward-word          # Alt+W - forward word
bindkey '^[b' backward-word         # Alt+B - backward word
```

**Status:** Working but user finds Alt unergonomic for frequent use.

---

## Viable Solutions

### Solution 1: Switch to Vi Mode (`bindkey -v`)

**Description:** Use zsh's built-in vi mode where you press `Esc` to enter normal mode, then use hjkl naturally.

**Pros:**
- Most vim-like experience
- Already have muscle memory from vim
- No key conflicts - normal mode is separate from insert mode
- Standard zsh feature, well-maintained

**Cons:**
- Requires `Esc` to enter normal mode (extra keystroke)
- Starts in insert mode by default (need indicator to know mode)
- Some emacs keybindings lost (Ctrl+A, Ctrl+E, etc.)
- Need to configure mode indicator in prompt

**Orphaned Keybindings (if implemented):**

Current emacs bindings that would need replacement:
```zsh
bindkey "^A" beginning-of-line      # Would need 0 or ^ in normal mode
bindkey "^E" end-of-line            # Would need $ in normal mode
bindkey "^R" history-incremental-search-backward  # / in normal mode
bindkey "^P" history-search-backward  # k in normal mode
bindkey "^Y" accept-and-hold        # Would lose this
bindkey "^N" insert-last-word       # Would lose this
```

**Investigation needed:**
- Check if vi mode supports insert-mode keybindings (can we keep Ctrl+A/E/R in insert mode?)
- How to display mode indicator (vi-mode-indicator plugin?)
- Can we bind `jk` or `jj` to exit insert mode (more ergonomic than Esc)?

---

### Solution 2: Ctrl+O Leader Key (tmux-style)

**Description:** Use `Ctrl+O` as a prefix key, then hjkl for navigation. Similar to how tmux uses `Ctrl+S` as prefix.

**Pros:**
- Single extra keystroke (`Ctrl+O h` instead of `h`)
- Ergonomic - Ctrl is on home row (caps lock remapped)
- Keeps all existing Ctrl keybindings
- Familiar pattern from tmux usage

**Cons:**
- Not as natural as pure hjkl
- Requires remembering prefix key
- Slightly slower than direct keybindings

**Orphaned Keybindings (if implemented):**

`Ctrl+O` current binding:
```
# Check current binding:
bindkey | grep '^"\\^O"'
# Default: accept-line-and-down-history
```

Would need to:
1. Unbind `Ctrl+O` from default
2. Create custom widget to handle prefix behavior
3. Implement timeout for prefix (like tmux)

**Implementation complexity:** Medium - requires custom zsh widget

**Example implementation:**
```zsh
# Pseudo-code for leader key behavior
function leader-navigation() {
  read -k 1 key
  case $key in
    h) zle backward-char ;;
    j) zle down-line-or-history ;;
    k) zle up-line-or-history ;;
    l) zle forward-char ;;
    w) zle forward-word ;;
    b) zle backward-word ;;
  esac
}
zle -N leader-navigation
bindkey '^O' leader-navigation
```

---

### Solution 3: Sacrifice Less-Used Ctrl Keys

**Description:** Rebind rarely-used Ctrl keys to hjkl navigation.

**Candidates for rebinding:**
- `Ctrl+N` - Currently: `insert-last-word` (rarely used)
- `Ctrl+P` - Currently: `history-search-backward` (duplicate of Ctrl+R)
- `Ctrl+Y` - Currently: `accept-and-hold` (rarely used)
- `Ctrl+G` - Currently: `send-break` (cancel)

**Proposed mapping:**
```zsh
bindkey '^P' backward-char       # Ctrl+P = h (left)
bindkey '^N' forward-char        # Ctrl+N = l (right)
bindkey '^[[A' up-line          # Up arrow = k (already bound)
bindkey '^[[B' down-line        # Down arrow = j (already bound)
```

**Pros:**
- Ergonomic Ctrl keybindings
- No mode switching
- Keeps most emacs bindings

**Cons:**
- Not hjkl (requires new muscle memory)
- Loses some useful features
- Ctrl+P/N are traditional emacs up/down - might be confusing

**Orphaned Keybindings (if implemented):**
```zsh
bindkey "^P" history-search-backward  # Would lose this
bindkey "^N" insert-last-word         # Would lose this
bindkey "^Y" accept-and-hold          # Keep this (not needed)
```

**Investigation needed:**
- Usage frequency analysis (histdb can help!)
- Survey of what features user actually uses

---

### Solution 4: Ctrl+Arrow Keys

**Description:** Use `Ctrl+Left/Right/Up/Down` for character movement.

**Proposed mapping:**
```zsh
bindkey "^[[1;5D" backward-char     # Ctrl+Left
bindkey "^[[1;5C" forward-char      # Ctrl+Right
bindkey "^[[1;5A" up-line          # Ctrl+Up
bindkey "^[[1;5B" down-line        # Ctrl+Down
```

**Pros:**
- Somewhat natural (arrows = direction)
- No conflicts with existing bindings
- Similar to other programs

**Cons:**
- Hand leaves home row (not ergonomic)
- Not vim-like
- Arrow keys are far from home position

**Orphaned Keybindings (if implemented):**
Check current Ctrl+Arrow bindings:
```zsh
bindkey | grep '1;5'
# Likely unbound, no conflicts
```

---

## Recommended Approach

**Priority ranking based on user requirements:**

### Option 1 (Recommended): Vi Mode with Insert-Mode Emacs Bindings

**Rationale:**
- User is heavy vim user (strongest muscle memory)
- Most natural for hjkl navigation
- Can configure best of both worlds (vi normal mode + emacs insert mode)

**Implementation steps:**
1. Switch to `bindkey -v`
2. Keep essential emacs bindings in insert mode:
   ```zsh
   bindkey -M viins '^A' beginning-of-line
   bindkey -M viins '^E' end-of-line
   bindkey -M viins '^R' history-incremental-search-backward
   bindkey -M viins '^W' backward-kill-word
   ```
3. Add mode indicator to prompt (powerlevel10k config)
4. Bind `jk` to exit insert mode (more ergonomic than Esc):
   ```zsh
   bindkey -M viins 'jk' vi-cmd-mode
   ```

**Audit checklist:**
- [ ] Test all existing Ctrl bindings in insert mode
- [ ] Verify history search works (Ctrl+R)
- [ ] Check autosuggestion integration (Ctrl+F)
- [ ] Test word movement (Ctrl+W, Alt+B/F/W)
- [ ] Verify mode indicator visibility

### Option 2 (Fallback): Ctrl+O Leader Key

**Rationale:**
- If vi mode feels too different
- Maintains all existing bindings
- Familiar from tmux experience

**Implementation steps:**
1. Create custom widget with timeout
2. Test prefix behavior with common commands
3. Document in keybindings.zsh

---

## Investigation Tasks for Next Session

### 1. Analyze Current Usage Patterns

Now that histdb is installed, query most-used keybindings:

```bash
# After a few days of usage:
histdb-top 50 | grep -E '^(Ctrl|Alt|Esc)'

# Check for Ctrl+P/N/Y usage specifically:
sqlite3 $HISTDB_FILE "
  SELECT cmd, COUNT(*) as count
  FROM commands
  WHERE cmd LIKE '%^P%' OR cmd LIKE '%^N%' OR cmd LIKE '%^Y%'
  GROUP BY cmd
  ORDER BY count DESC
"
```

### 2. Test Vi Mode in Isolated Session

```bash
# Create test environment
zsh -f  # Start without config
bindkey -v
# Test navigation, mode switching, etc.
```

### 3. Benchmark Mode-Switch Speed

How fast can you press `jk` vs `Esc`? Does it feel natural?

### 4. Check WezTerm Integration

Verify terminal sends correct key codes for Ctrl+Arrow combinations:
```bash
cat -v
# Press: Ctrl+Left, Ctrl+Right, etc.
# Document actual escape sequences received
```

---

## Related Files

- **Config:** `config/zsh/keybindings.zsh` - All keybinding definitions
- **Docs:** `CLAUDE.md` - Unified window management strategy
- **Docs:** `README.md` - Complete keybinding reference
- **Plugin:** `zinitrc` - Zsh plugin management (zsh-autosuggestions, etc.)
- **History:** `config/zsh/histdb.zsh` - Command tracking (use for usage analysis)

---

## Questions for User

1. **Vi mode preference:** Would you be willing to use Esc/jk to enter normal mode for navigation? Or does that feel too disruptive?

2. **Usage frequency:** How often do you use these current bindings?
   - `Ctrl+P` (history-search-backward)
   - `Ctrl+N` (insert-last-word)
   - `Ctrl+Y` (accept-and-hold)

3. **Leader key tolerance:** Is one extra keystroke (`Ctrl+O h` instead of `h`) acceptable, or does it break flow?

4. **Current ergonomics:** Is your Caps Lock remapped to Ctrl? (Affects Ctrl key ergonomics)

---

## Success Criteria

Navigation solution should:
- [ ] Allow hjkl-style movement without leaving home row
- [ ] Not break essential shell functionality (Ctrl+C, Ctrl+D, Ctrl+R, etc.)
- [ ] Feel natural after 1-2 days of use
- [ ] Work consistently with zsh-autosuggestions (Ctrl+F to accept)
- [ ] Integrate with existing unified keybinding strategy

---

## Current Keybinding Inventory

**Essential (must preserve):**
```zsh
^A - beginning-of-line
^C - interrupt (system)
^D - delete-char-or-list / exit (system)
^E - end-of-line
^K - kill-line
^L - clear-screen
^R - history-incremental-search-backward
^W - backward-kill-word
^Z - suspend (system, but Ctrl+S z in tmux)
```

**Less critical (potential candidates for rebinding):**
```zsh
^N - insert-last-word
^P - history-search-backward (duplicate of Ctrl+R)
^Y - accept-and-hold
^G - send-break
^O - accept-line-and-down-history
```

**Currently vim-like (via Alt+):**
```zsh
Alt+h - backward-char
Alt+j - down-line-or-history
Alt+k - up-line-or-history
Alt+l - forward-char
Alt+w - forward-word
Alt+b - backward-word
Alt+f - forward-word
```

**Arrow key combos (available):**
```zsh
Ctrl+Left/Right - (check if bound)
Ctrl+Up/Down - (check if bound)
Alt+Left/Right - forward/backward-word
```

---

## Next Steps

1. **Immediate:** User tests current Alt+hjkl implementation for a few days
2. **After testing:** Collect usage data from histdb
3. **Decision point:** Based on ergonomics feedback, implement either:
   - Vi mode with emacs insert bindings (Option 1)
   - Ctrl+O leader key (Option 2)
4. **Validation:** Test new bindings for 2-3 days, gather feedback
5. **Documentation:** Update README.md with final keybinding strategy

---

## Notes

- User already has unified window/pane management across vim/tmux/WezTerm
- Caps Lock → Ctrl remapping status: **Unknown** (affects ergonomics assessment)
- WSL2 environment may have terminal key code quirks (test Ctrl+Arrow sequences)
- Powerlevel10k prompt supports mode indicators (configure for vi mode if chosen)

---

## References

- [Zsh Vi Mode Documentation](https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Keymaps)
- [zsh-vi-mode plugin](https://github.com/jeffreytse/zsh-vi-mode) - Enhanced vi mode
- Current keybindings.zsh audit: See "Current Keybinding Inventory" above
- Unified keybindings strategy: See CLAUDE.md lines 181-223
