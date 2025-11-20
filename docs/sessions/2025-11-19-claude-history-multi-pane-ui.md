# Claude History Multi-Pane UI Redesign - Session Documentation

**Date:** 2025-11-19
**Goal:** Fix the claude-history viewer to match the original design: a multi-pane interface with sessions list, entries list, and live diff preview

## Problem Statement

In the previous session (2025-11-19-claude-history-viewer.md), a history tracking system was built but the UI implementation was completely wrong. The implementation created a simple flat picker showing all entries in one list, but the intended design was a sophisticated 3-pane interface with:

1. **Sessions list** (left pane) - Show all Claude Code sessions
2. **Entries list** (right pane) - Show commands/edits for selected session
3. **Diff preview** (bottom pane) - Auto-updating preview of selected entry

Additionally, there was no persistence - history was lost when Neovim closed, and all directories shared the same history.

## Solution Overview

Completely rewrote the picker UI using `Snacks.layout` for custom multi-pane layout, added persistent storage to disk, and scoped history to the working directory where Claude Code is running.

## Architecture Changes

### 1. Multi-Pane Layout Design

**Layout Structure:**
```
┌──────────────────┬─────────────────────────┐
│   Sessions List  │   Bash Commands &       │
│   (30% width)    │   File Edits            │
│                  │   (70% width)           │
│   • Session 1    │   (for selected session)│
│   • Session 2    │                         │
│   • Session 3    │   • git status          │
│                  │   • [Edit] foo.lua      │
│                  │   • task -l             │
│                  │                         │
└──────────────────┴─────────────────────────┘
│   Diff Preview (40% height)                │
│   (auto-updates as you navigate)           │
└────────────────────────────────────────────┘
```

**Why Snacks.layout instead of Snacks.picker?**

The picker component is hardcoded to only support 3 window types: `input`, `list`, and `preview`. Our design needs custom windows with different behaviors:
- A session list that updates the entries list when selected
- An entries list that updates the diff preview on cursor movement
- A diff preview that shows different content types (diffs, bash commands, files)

Using `Snacks.layout.new()` gives us full control over window creation, buffer management, and keybindings.

### 2. Persistent Storage

**Storage Location:** `~/.local/share/nvim/claude-history/`

**File Naming:** Each directory gets a separate JSON file based on the sanitized path:
- `/Users/ryan/dotfiles` → `_Users_ryan_dotfiles.json`
- `/Users/ryan/projects/foo` → `_Users_ryan_projects_foo.json`

**Data Structure:**
```json
{
  "cwd": "/Users/ryan/dotfiles",
  "current_session_id": "1732051234",
  "sessions": {
    "1732051234": {
      "id": "1732051234",
      "started_at": 1732051234,
      "entries": [
        {
          "type": "diff",
          "timestamp": 1732051250,
          "file_path": "/path/to/file.lua",
          "old_file_contents": "...",
          "new_file_contents": "...",
          "tab_name": "Update config"
        },
        {
          "type": "bash",
          "timestamp": 1732051260,
          "command": "git status"
        }
      ]
    }
  }
}
```

**Auto-save Triggers:**
- Every `add_entry()` call
- Every `start_session()` call
- Every `clear_current_session()` or `clear_all_sessions()` call

**Loading:**
- On Claude Code terminal open (`TermOpen` autocmd)
- Detects CWD from terminal buffer
- Loads existing sessions from disk (if file exists)
- Continues current session or starts new one

### 3. Directory Scoping

**CWD Detection:**

When a Claude Code terminal opens, the tracker detects the working directory:

```lua
local cwd = vim.fn.getcwd(-1, args.buf)  -- Buffer-local CWD
if not cwd or cwd == "" then
  cwd = vim.fn.getcwd()  -- Fall back to global CWD
end
```

This ensures history is scoped to where Claude Code is actually running, not where Neovim was opened.

**Isolation:**

Each directory maintains completely separate history:
- Opening `<leader>ah` in `~/dotfiles` shows only `~/dotfiles` sessions
- Opening `<leader>ah` in `~/projects/foo` shows only `~/projects/foo` sessions
- No cross-contamination between project histories

## Implementation Details

### File: `config/nvim/lua/claude-history/picker.lua`

**Complete Rewrite** - Changed from simple picker to custom layout.

**Key Functions:**

1. **`populate_sessions(ui)`** - Renders session list in left pane
   - Formats as "Session N [HH:MM:SS] (X entries)"
   - Updates `ui.sessions` table for reference

2. **`populate_entries(ui)`** - Renders entries for selected session
   - Shows bash commands, diffs, saves, tool calls
   - Uses icons (🐚 🔧 📝 💾) for visual clarity
   - Updates `ui.entries` table for reference

3. **`update_diff_preview(ui)`** - Renders preview based on current entry
   - **For diffs:** Shows side-by-side OLD | NEW comparison (truncated to 50 lines)
   - **For bash:** Shows command details and timestamp
   - **For files:** Shows file preview with syntax highlighting
   - **For others:** Shows JSON representation

4. **`setup_keybindings(ui, buf, is_sessions)`** - Different bindings per pane
   - **Sessions pane:**
     - `<CR>` or `<Tab>` - Select session, jump to entries
     - `q` or `<Esc>` - Close UI

   - **Entries pane:**
     - `j/k` or `<Up>/<Down>` - Navigate (auto-updates preview!)
     - `<CR>` - Open full diff in new tab (for diffs) or open file
     - `<Tab>` - Return to sessions pane
     - `q` or `<Esc>` - Close UI

**Layout Definition:**

```lua
snacks.layout.new({
  wins = {
    sessions = { buf = sessions_buf, title = " Sessions " },
    entries = { buf = entries_buf, title = " Commands & Edits " },
    diff = { buf = diff_buf, title = " Preview " },
  },
  layout = {
    box = "vertical",
    width = 0.9,
    height = 0.9,
    {
      box = "horizontal",
      height = 0.6,  -- Top 60% for lists
      { win = "sessions", width = 0.3, border = true },
      { win = "entries", width = 0.7, border = true },
    },
    { win = "diff", height = 0.4, border = true },  -- Bottom 40% for preview
  },
})
```

### File: `config/nvim/lua/claude-history/init.lua`

**Added Persistence Layer**

**New Functions:**

1. **`sanitize_path(path)`** - Converts `/foo/bar` → `_foo_bar`
2. **`get_storage_path(cwd)`** - Returns full path to JSON file for directory
3. **`save_to_disk()`** - Writes current state to JSON
4. **`load_from_disk(cwd)`** - Reads existing sessions from JSON
5. **`M.init(cwd)`** - Initialize history for a specific directory

**Modified Functions:**

- `start_session()` - Now calls `save_to_disk()`
- `add_entry()` - Now calls `save_to_disk()`
- `clear_current_session()` - Now calls `save_to_disk()`
- `clear_all_sessions()` - Now calls `save_to_disk()`

**New Fields:**

- `M.current_cwd` - Tracks which directory this history belongs to

### File: `config/nvim/lua/claude-history/tracker.lua`

**Updated Terminal Tracking**

**Changes in `setup_terminal_tracking()`:**

```lua
-- Detect CWD from terminal buffer
local cwd = vim.fn.getcwd(-1, args.buf)
if not cwd or cwd == "" then
  cwd = vim.fn.getcwd()
end

-- Initialize history for this directory (loads existing sessions)
history.init(cwd)

-- Start session if needed
if not history.current_session_id then
  history.start_session()
end

-- Notify user
vim.notify(
  string.format("Claude history tracking started for: %s", vim.fn.fnamemodify(cwd, ":~")),
  vim.log.levels.INFO
)
```

**Removed:**

- `history.start_session()` call from `wrap_tools()` (no longer starts session during wrapping, only during terminal open)

### File: `config/nvim/lua/claude-history/commands.lua`

**Updated Commands**

1. **`:ClaudeHistoryInfo`** - Now shows:
   - Current directory (formatted with `~`)
   - Current session ID
   - Total sessions count
   - Current entries count
   - Storage location path

2. **`:ClaudeHistorySeed`** - Now:
   - Calls `history.init(cwd)` before seeding
   - Creates 3 test sessions instead of 1
   - Shows total sessions and entries in notification

## User Experience Flow

### Opening History Viewer

1. User presses `<leader>ah` (or runs `:ClaudeHistory`)
2. UI opens with 3 panes visible
3. **Left pane** shows list of sessions for current directory
4. **Right pane** shows entries from Session 1 (auto-selected)
5. **Bottom pane** shows preview of first entry

### Navigation Flow

1. **In Sessions List (left):**
   - Use `j/k` to browse sessions
   - Press `<CR>` or `<Tab>` to select session
   - Cursor jumps to entries list (right pane)
   - Entries list updates to show selected session's entries

2. **In Entries List (right):**
   - Use `j/k` to browse entries
   - **Preview auto-updates** on every cursor movement!
   - If entry is a diff → bottom pane shows side-by-side comparison
   - If entry is bash → bottom pane shows command details
   - If entry is file → bottom pane shows file preview
   - Press `<CR>` to open full diff in new tab (for diffs) or open file
   - Press `<Tab>` to go back to sessions list

3. **Closing:**
   - Press `q` or `<Esc>` from any pane to close UI

### Persistence Flow

1. **First time in a directory:**
   - Open Claude Code terminal
   - Tracker detects CWD: `/Users/ryan/dotfiles`
   - Tries to load: `~/.local/share/nvim/claude-history/_Users_ryan_dotfiles.json`
   - File doesn't exist → starts fresh
   - Creates new session
   - As Claude works, entries are auto-saved

2. **Second time (after restart):**
   - Open Claude Code terminal in same directory
   - Tracker detects CWD: `/Users/ryan/dotfiles`
   - Loads existing file: `_Users_ryan_dotfiles.json`
   - Restores all previous sessions
   - Continues current session (or starts new one)
   - Previous history is immediately available in `<leader>ah`

3. **Different directory:**
   - Open Claude Code in: `/Users/ryan/projects/foo`
   - Tracker detects different CWD
   - Loads different file: `_Users_ryan_projects_foo.json`
   - Shows only sessions from `foo` project
   - Completely isolated from `dotfiles` history

## Testing Process

### Test 1: Multi-Pane Layout

```vim
:ClaudeHistoryClearAll
:ClaudeHistorySeed
:ClaudeHistory
```

**Expected:**
- UI opens with 3 panes
- Left: 3 sessions listed
- Right: Entries from Session 3 (newest)
- Bottom: Preview of first entry
- Navigating with `j/k` in right pane updates preview

### Test 2: Session Selection

```vim
" In sessions list (left pane)
" Press j to move to Session 2
" Press <CR>
```

**Expected:**
- Cursor jumps to right pane
- Right pane now shows Session 2's entries
- Bottom pane shows preview of Session 2's first entry

### Test 3: Diff Preview

```vim
" Navigate to a diff entry in right pane
```

**Expected:**
- Bottom pane shows:
  ```
  === Diff Preview ===
  OLD | NEW
  ────────────────────────────────
  local M = {}            | local M = {}
                          |
  function M.hello()      | function M.hello()
    print("Hello, World") |   print("Hello, Claude!")
  ...
  ```

### Test 4: Persistence

```vim
:ClaudeHistorySeed
:ClaudeHistoryInfo
" Note the storage path and session count
:qa
" Restart Neovim
:ClaudeHistoryInfo
" Should show same session count
:ClaudeHistory
" Should see all 3 sessions still there
```

### Test 5: Directory Scoping

```vim
" In ~/dotfiles
:ClaudeHistorySeed
:ClaudeHistoryInfo  " Shows: Current Directory: ~/dotfiles

" cd to different directory
:cd ~/projects/test
" Open new Claude Code terminal there
:ClaudeHistoryInfo  " Shows: Current Directory: ~/projects/test
:ClaudeHistory  " Shows empty or different sessions
```

## Challenges & Solutions

### Challenge 1: Understanding the Original Intent

**Problem:** Previous implementation was a flat list, but user wanted multi-pane interface

**Discovery:** User clarified during this session: "swap around the right and left panes" and described the interaction model with Tab navigation and live preview updates

**Solution:** Asked clarifying questions to understand exact layout and interaction model before implementing

### Challenge 2: Snacks Picker Limitations

**Problem:** Snacks picker only supports `input`, `list`, and `preview` windows

**Investigation:** Read `snacks.nvim/lua/snacks/picker/config/layouts.lua` and saw all layouts use only these 3 window types

**Solution:** Used `Snacks.layout.new()` directly instead of `Snacks.picker.pick()` to create custom windows with full control

### Challenge 3: Live Preview Updates

**Problem:** Preview needs to update as user navigates entries, not just on Enter

**Solution:** Wrapped `j/k` navigation keys to:
1. Move cursor with `vim.cmd("normal! j")`
2. Update `ui.current_entry_idx`
3. Call `update_diff_preview(ui)`

This creates a smooth experience where preview updates instantly as you navigate.

### Challenge 4: JSON Encoding Large Diffs

**Problem:** Diff entries contain full file contents which can be large

**Consideration:** Could this cause performance issues with JSON encoding?

**Decision:**
- JSON encoding is fast enough for typical file sizes
- Auto-save on every entry keeps state always in sync
- If performance becomes an issue, can batch saves or debounce
- Current approach favors data safety (never lose history)

### Challenge 5: Path Sanitization

**Problem:** File paths contain `/` which can't be used in filenames

**Solution:** `sanitize_path()` replaces all problematic characters (`/\:*?"<>|`) with underscores

**Result:**
- `/Users/ryan/dotfiles` → `_Users_ryan_dotfiles.json`
- Works cross-platform (handles both `/` and `\`)
- No collisions (full path preserved, just escaped)

## Files Changed

### Modified Files

1. **`config/nvim/lua/claude-history/picker.lua`**
   - Complete rewrite from ~258 lines to ~404 lines
   - Changed from Snacks picker to custom Snacks layout
   - Added 3-pane interface with custom buffers
   - Added live preview updates on navigation
   - Added keybindings for pane switching

2. **`config/nvim/lua/claude-history/init.lua`**
   - Added persistence layer (~88 lines of new code)
   - Added `sanitize_path()`, `get_storage_path()`, `save_to_disk()`, `load_from_disk()`
   - Added `M.init(cwd)` for directory-scoped initialization
   - Modified all mutation functions to call `save_to_disk()`
   - Added `M.current_cwd` field

3. **`config/nvim/lua/claude-history/tracker.lua`**
   - Updated `setup_terminal_tracking()` to detect CWD and initialize history
   - Removed `history.start_session()` from `wrap_tools()`
   - Added user notification when tracking starts

4. **`config/nvim/lua/claude-history/commands.lua`**
   - Enhanced `:ClaudeHistoryInfo` to show CWD, session count, storage location
   - Updated `:ClaudeHistorySeed` to initialize with CWD before seeding
   - Updated `:ClaudeHistorySeed` to create 3 sessions instead of 1

### New Files

- **`docs/sessions/2025-11-19-claude-history-multi-pane-ui.md`** (this file)

## Future Enhancements

### Potential Improvements

1. **Better Diff Rendering**
   - Current: Simple side-by-side truncated to 50 lines
   - Future: Use `vim.diff()` for proper diff highlighting
   - Future: Use full window height, scrollable

2. **Search/Filter**
   - Add search across sessions
   - Filter by entry type (bash, diff, save)
   - Filter by file path or command pattern

3. **Session Management**
   - Rename sessions
   - Add session notes/descriptions
   - Merge sessions
   - Export session to markdown report

4. **Performance Optimizations**
   - Lazy load session entries (only load when selected)
   - Debounce auto-save (batch writes)
   - Paginate large entry lists

5. **Multi-Directory View**
   - Optional: View history from all directories
   - Grouped by directory
   - Jump to directory's history

6. **Integration Improvements**
   - Link to git commits made during session
   - Link to files in entries (jump to file)
   - Replay bash commands (execute again)

7. **Export Capabilities**
   - Export to markdown report
   - Export to JSON for external tools
   - Generate session summaries with AI

## Key Learnings

### 1. Always Clarify UI Requirements

When a user says "I don't see any change in behavior," don't assume it's a bug. Ask:
- What did you expect to see?
- What are you actually seeing?
- Can you describe the ideal interaction?

In this case, the entire UI paradigm was wrong - not just a minor fix.

### 2. Read the Library Source

Don't assume a library can do what you need. Read the source:
- `snacks.nvim/lua/snacks/picker/config/layouts.lua` showed picker limitations
- `snacks.nvim/docs/layout.md` showed layout capabilities
- Understanding both led to the right solution

### 3. Progressive Enhancement

Started with core functionality:
1. Multi-pane layout (visual structure)
2. Navigation (interaction model)
3. Preview updates (reactivity)
4. Persistence (durability)
5. Directory scoping (isolation)

Each layer built on the previous. If we'd tried to do everything at once, debugging would be much harder.

### 4. Auto-Save Everything

For tools like this, auto-saving on every change is the right choice:
- Users don't want to manually save history
- History is valuable - losing it is unacceptable
- Performance cost is negligible for this use case
- Simplifies mental model (no "did I save?" questions)

### 5. Test with Realistic Data

The `:ClaudeHistorySeed` command was crucial for testing:
- Creates realistic multi-session scenario
- Includes all entry types (bash, diff, tool, save)
- Includes actual diff content (not just metadata)
- Enables quick iteration without waiting for real Claude activity

## Related Documentation

### Previous Session

- **`docs/sessions/2025-11-19-claude-history-viewer.md`** - Initial implementation (now obsolete UI approach)
- **`docs/sessions/2025-01-19-claude-history-tracker.md`** - Original tracker implementation

### User Documentation

- **`config/nvim/lua/claude-history/README.md`** - User-facing documentation (should be updated)

### Code References

- Sessions list rendering: `config/nvim/lua/claude-history/picker.lua:77-95`
- Entries list rendering: `config/nvim/lua/claude-history/picker.lua:98-120`
- Diff preview rendering: `config/nvim/lua/claude-history/picker.lua:123-188`
- Persistence layer: `config/nvim/lua/claude-history/init.lua:12-88`
- CWD detection: `config/nvim/lua/claude-history/tracker.lua:94-99`
- Layout definition: `config/nvim/lua/claude-history/picker.lua:361-384`

### External Resources

- Snacks.nvim layout docs: `~/.local/share/nvim/lazy/snacks.nvim/docs/layout.md`
- Snacks.nvim picker layouts: `~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/config/layouts.lua`

## Note for Future Claude Sessions

**Important:** When asked about how the claude-history feature was implemented or how to modify it, check this documentation first. The initial session (2025-11-19-claude-history-viewer.md) has an incorrect UI implementation that was completely replaced in this session.

**Key Context:**
- History is **persistent** (saved to `~/.local/share/nvim/claude-history/`)
- History is **directory-scoped** (each project has separate history)
- UI is a **custom 3-pane layout** (not a simple picker)
- Preview updates **live** as you navigate (not just on Enter)

**Common Questions:**

Q: Where is history stored?
A: `~/.local/share/nvim/claude-history/[sanitized-path].json`

Q: Why don't I see history from another project?
A: History is scoped to the directory where Claude Code is running

Q: How do I see old sessions?
A: Press `<leader>ah`, navigate sessions list (left pane), press Enter to view entries

Q: Can I export history?
A: Not yet - see "Future Enhancements" section above

Q: How do I clear history for current directory?
A: `:ClaudeHistoryClearAll`

Q: The UI looks different than described in the first session doc?
A: That's expected - this session completely replaced the UI implementation
