# Claude Code History Tracker

Tracks all MCP tool invocations and terminal commands executed by Claude Code during your session.

## Features

- 📊 **Session-based tracking** - Automatically starts new sessions when Claude Code terminal opens
- 🔧 **MCP tool tracking** - Captures all tool calls (file opens, diffs, saves, diagnostics)
- 🐚 **Bash command tracking** - Extracts and tracks shell commands from terminal output
- 🔍 **Snacks picker integration** - Beautiful, consistent UI with your existing workflow
- 💾 **Multi-session support** - View current session or all historical sessions

## Usage

### Keybindings

- `<leader>ah` - Open history picker (current session)
- `<leader>aH` - Open history picker (all sessions)

### Commands

- `:ClaudeHistory` - Open history picker (current session)
- `:ClaudeHistoryAll` - Open history picker (all sessions)
- `:ClaudeHistoryClear` - Clear current session history
- `:ClaudeHistoryClearAll` - Clear all session history
- `:ClaudeHistoryNewSession` - Start a new session manually
- `:ClaudeHistoryInfo` - Show current session info

### Picker Actions

In the history picker:

- `<CR>` - Open file (if entry has file path) or show details
- `<c-x>` - Open file in horizontal split
- `<c-v>` - Open file in vertical split
- Preview pane shows file contents or entry details

## How It Works

### MCP Tool Tracking

The tracker wraps `claudecode.tools.handle_invoke()` to intercept all MCP tool calls:

- **openFile** - Tracks when Claude opens/views files
- **open_diff** - Tracks diff proposals
- **save_document** - Tracks file saves
- **get_diagnostics** - Tracks diagnostic checks
- And all other MCP tools

### Terminal Command Tracking

When a Claude Code terminal buffer is opened:

1. Monitors buffer for new lines (every 1 second)
2. Extracts commands using common prompt pattern matching
3. Stores commands with timestamps

Recognized prompts:
- `$`, `#`, `>` (bash/sh)
- `❯` (starship/oh-my-zsh)
- `➜` (common custom prompts)

### Session Management

- **Auto session start** - Creates new session when terminal opens via `TermOpen` autocmd
- **Manual sessions** - Use `:ClaudeHistoryNewSession` to manually start
- **Persistent storage** - Sessions stored in memory for the Neovim instance

## Entry Types

History entries are categorized by type:

- 🔧 **tool** - Generic MCP tool invocation
- 🐚 **bash** - Shell command execution
- 📝 **diff** - Diff proposal
- 💾 **save** - File save operation

## Data Structure

```lua
---@class HistoryEntry
---@field type "tool"|"bash"|"diff"|"save"
---@field timestamp number
---@field tool_name string? -- For tool/diff/save entries
---@field params table? -- Tool parameters
---@field command string? -- For bash entries
---@field file_path string? -- Associated file if applicable
---@field result table? -- Tool result if successful
```

## Troubleshooting

### Commands not being captured

The terminal tracking uses heuristics to detect commands. If commands aren't being captured:

1. Check your shell prompt format
2. Add your prompt pattern to `tracker.lua:extract_command()`
3. Use `:ClaudeHistoryInfo` to verify session is active

### No history showing

- Ensure Claude Code terminal was opened (triggers session start)
- Check `:ClaudeHistoryInfo` to see entry count
- Try `:ClaudeHistoryAll` to see all sessions

### Performance concerns

- Terminal tracking polls every 1 second (configurable in `tracker.lua`)
- History stored in memory only (cleared on Neovim exit)
- Timer automatically stops when buffer is closed

## Future Enhancements

Potential improvements:

- [ ] Persistent storage (save to file between sessions)
- [ ] Export history to JSON/CSV
- [ ] Better command detection (parse shell output more intelligently)
- [ ] Grouping related entries (e.g., git commands in a sequence)
- [ ] Search/filter by file, command type, or time range
- [ ] Replay functionality for bash commands
- [ ] Integration with undo/redo for diff operations
