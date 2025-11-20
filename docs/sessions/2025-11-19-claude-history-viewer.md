# Claude Code History Viewer - Session Documentation

**Date:** 2025-11-19
**Goal:** Create a history viewer for Claude Code sessions that tracks tool invocations, bash commands, and file diffs

## Overview

Built a comprehensive history tracking and viewing system for the `claudecode.nvim` plugin. The system captures all MCP tool calls, terminal commands, and file diffs during Claude Code sessions, then provides an interactive Snacks picker interface to browse and review the history.

## Problem Statement

When working with Claude Code, there was no way to:
1. Review what files Claude had opened or modified
2. See the actual diffs Claude proposed
3. Track bash commands that were executed
4. Maintain a session history of all Claude's actions

This made it difficult to audit Claude's work or revisit previous changes.

## Solution Architecture

### Components Created

1. **History Tracker** (`config/nvim/lua/claude-history/init.lua`)
   - In-memory session storage
   - Session management (create, clear, get entries)
   - Entry types: tool, bash, diff, save

2. **Tool Wrapper** (`config/nvim/lua/claude-history/tracker.lua`)
   - Wraps `claudecode.tools.handle_invoke()` to intercept MCP calls
   - Captures full diff content (old/new file contents)
   - Monitors terminal buffers for bash commands
   - Auto-starts sessions when Claude Code terminal opens

3. **Snacks Picker Interface** (`config/nvim/lua/claude-history/picker.lua`)
   - Lists all history entries with timestamps and icons
   - Preview pane shows file contents or proposed changes
   - Diff viewer opens side-by-side comparison in new tab
   - Actions: view diff, jump to file, open current state

4. **User Commands** (`config/nvim/lua/claude-history/commands.lua`)
   - `:ClaudeHistory` - View current session
   - `:ClaudeHistoryAll` - View all sessions
   - `:ClaudeHistoryClear` / `:ClaudeHistoryClearAll` - Clear history
   - `:ClaudeHistoryNewSession` - Start new session
   - `:ClaudeHistoryInfo` - Show session stats
   - `:ClaudeHistorySeed` - Seed test data

## Implementation Details

### Key Technical Decisions

1. **In-Memory Storage**
   - History stored in Lua tables (not persisted to disk)
   - Cleared on Neovim exit
   - Simple, fast, no serialization overhead
   - Future enhancement: add persistence if needed

2. **Tool Wrapping Strategy**
   - Wraps `claudecode.tools.handle_invoke()` at runtime
   - Deferred initialization (1000ms delay) to wait for plugin load
   - Captures params before and result after tool execution
   - Non-intrusive - doesn't modify tool behavior

3. **Diff Content Capture**
   - For `openDiff` tool calls, capture:
     - `old_file_path` - original file location
     - `new_file_path` - target file location
     - `old_file_contents` - read from disk before change
     - `new_file_contents` - Claude's proposed changes
     - `tab_name` - description of the change
   - Enables full diff replay without git history

4. **Snacks Picker Integration**
   - Uses `items` array (not `source` or `finder`)
   - Custom preview function for diffs vs files
   - Custom confirm action handles different entry types
   - Custom keybinding `<c-o>` to jump to current file state

### Data Structure

```lua
---@class HistoryEntry
---@field type "tool"|"bash"|"diff"|"save"
---@field timestamp number
---@field tool_name string?
---@field params table?
---@field command string?
---@field file_path string?
---@field old_file_path string?
---@field new_file_path string?
---@field old_file_contents string?
---@field new_file_contents string?
---@field tab_name string?
---@field result table?
```

## Challenges & Solutions

### Challenge 1: Understanding the Execution Context

**Problem:** Initially unclear if running in CLI or plugin context
**Solution:** Confirmed we're in `claudecode.nvim` terminal, not standalone CLI. The tracker hooks into the plugin's MCP tool handler.

### Challenge 2: Snacks Picker API Misuse

**Problem:** First implementation passed `source` object instead of string/items
**Error:** `attempt to concatenate a table value`
**Solution:** Changed to use `items` array directly with inline preview/confirm functions

### Challenge 3: Blank Rows in Picker

**Problem:** Picker showed blank rows for some entries
**Solution:** Ensured all entries have valid `text` field from `format_entry()` function

### Challenge 4: Diff Display Requirements

**Problem:** User wanted to see both the diff AND ability to jump to current file
**Solution:**
- Enter key: Opens side-by-side diff in new tab
- `<c-o>` key: Jumps to current file state
- Preview pane: Shows Claude's proposed changes

### Challenge 5: Tool Name Case Inconsistency

**Problem:** MCP tools use different naming conventions
**Fixed:**
- `openDiff` (camelCase for openDiff tool)
- `open_file` (snake_case for other tools)
- Updated tracker to match actual tool names

## Keybindings

- `<leader>ah` - Open Claude history (current session)
- `<leader>aH` - Open Claude history (all sessions)

### In Picker:
- `<CR>` - View diff or open file
- `<c-o>` - Open current file state
- `<c-x>` - Open in horizontal split
- `<c-v>` - Open in vertical split

## Testing

Created `:ClaudeHistorySeed` command that generates realistic test data:
- File open events
- Bash commands (git status, task -l, fd)
- Tool invocations (get_diagnostics, Grep)
- Diff with actual before/after content
- Save operations

Enables testing the UI without waiting for real Claude Code activity.

## Files Changed

### New Files
- `config/nvim/lua/claude-history/init.lua` - Core history storage
- `config/nvim/lua/claude-history/tracker.lua` - Tool/command tracking
- `config/nvim/lua/claude-history/picker.lua` - Snacks picker UI
- `config/nvim/lua/claude-history/commands.lua` - User commands
- `config/nvim/lua/claude-history/README.md` - Documentation

### Modified Files
- `config/nvim/lua/plugins/claude-code.lua` - Setup history tracker
- `config/nvim/lua/config/keymaps.lua` - Add history keybindings

### Deleted Files (Relocated)
- `config/nvim/lua/plugins/claude-history/*` → `config/nvim/lua/claude-history/*`
- Moved out of `plugins/` to be a standalone module

## Future Enhancements

Potential improvements documented in README:
- [ ] Persistent storage (save to file between sessions)
- [ ] Export history to JSON/CSV
- [ ] Better command detection (parse shell output more intelligently)
- [ ] Grouping related entries (e.g., git commands in a sequence)
- [ ] Search/filter by file, command type, or time range
- [ ] Replay functionality for bash commands
- [ ] Integration with undo/redo for diff operations

## Usage Pattern

1. **Automatic capture** - Works transparently when using Claude Code
2. **Review session** - `:ClaudeHistory` to see what Claude did
3. **Inspect diffs** - Navigate to diff entries and press Enter
4. **Jump to files** - Review current state with `<c-o>`
5. **Clear history** - `:ClaudeHistoryClear` when starting new work

## Lessons Learned

1. **Read the plugin source** - Understanding `claudecode.nvim` internals was crucial for proper tool wrapping
2. **Check API docs** - Snacks picker API differs from Telescope; needed to adapt
3. **Defer initialization** - Plugin loading order matters; use `vim.defer_fn()` for hooks
4. **Capture comprehensively** - For diffs, need both old and new content to enable replay
5. **Test with seed data** - Mock data enables UI testing without full integration
6. **Progressive enhancement** - Started simple (flat list), can evolve to multi-panel later

## Related Documentation

- `config/nvim/lua/claude-history/README.md` - User-facing documentation
- Snacks picker: `~/.local/share/nvim/lazy/snacks.nvim/lua/snacks/picker/`
- claudecode.nvim: `~/.local/share/nvim/lazy/claudecode.nvim/`
