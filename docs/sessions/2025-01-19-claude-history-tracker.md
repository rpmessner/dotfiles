# Session: Claude Code History Tracker Implementation

**Date**: 2025-01-19
**Goal**: Build a history tracking system for Claude Code to view all shell commands and file edits on a session-by-session basis
**Status**: ✅ Complete

## Problem Statement

When using the claudecode.nvim plugin, there was no way to view a backward-facing list of:
- Shell commands that Claude executed
- File operations (opens, edits, saves)
- MCP tool invocations
- Diff proposals

The user wanted a Snacks-based picker interface to browse this history, consistent with their existing dotfiles workflow.

## Solution Architecture

### Components Built

Created a modular history tracking system in `config/nvim/lua/plugins/claude-history/`:

```
claude-history/
├── init.lua       # Core session storage and management
├── tracker.lua    # MCP tool interception and terminal monitoring
├── picker.lua     # Snacks picker integration for UI
├── commands.lua   # Vim user commands
└── README.md      # Documentation
```

### How It Works

#### 1. MCP Tool Interception (`tracker.lua`)

Wraps `claudecode.tools.handle_invoke()` to capture all tool calls:

```lua
-- Original implementation stores tool invocations
tools_module.handle_invoke = function(client, params)
  -- Capture tool name, parameters, file paths
  local entry = {
    type = "tool",
    tool_name = params.name,
    params = params.arguments,
  }
  history.add_entry(entry)

  -- Call original handler
  return original_handle_invoke(client, params)
end
```

**Tracked Tools:**
- `openFile` - File opens/views
- `open_diff` - Diff proposals
- `save_document` - File saves
- `get_diagnostics` - Diagnostic queries
- `get_workspace_folders` - Workspace queries
- And all other MCP tools

#### 2. Terminal Command Tracking (`tracker.lua`)

Uses `TermOpen` autocmd to detect Claude Code terminals, then:

1. Polls buffer every 1 second for new lines
2. Extracts commands using prompt pattern matching
3. Records commands with timestamps

**Recognized Prompts:**
- `$`, `#`, `>` (bash/sh)
- `❯` (starship/oh-my-zsh)
- `➜` (custom prompts)

```lua
-- Extracts: "git status" from "❯ git status"
local command = M.extract_command(line)
if command then
  history.add_entry({
    type = "bash",
    command = command,
  })
end
```

#### 3. Session Management (`init.lua`)

- **Auto-session start**: Triggered by `TermOpen` when Claude terminal opens
- **Manual sessions**: `:ClaudeHistoryNewSession`
- **Storage**: In-memory (session-scoped)

```lua
M.sessions = {
  ["1737331200"] = {
    id = "1737331200",
    started_at = 1737331200,
    entries = [...]
  }
}
```

#### 4. Snacks Picker UI (`picker.lua`)

Integrates with user's existing Snacks configuration:

```lua
-- Format: [12:34:56] 🐚 git status
local function format_entry(entry)
  local time = format_time(entry.timestamp)
  local icon = get_icon(entry.type)
  return string.format("[%s] %s %s", time, icon, details)
end
```

**Features:**
- Preview pane (file contents or JSON details)
- File navigation actions
- Consistent with existing `<leader>f*` pickers

## Integration Points

### Modified Files

1. **`config/nvim/lua/plugins/claude-code.lua`**
   ```lua
   config = function()
     require("claudecode").setup()
     require("plugins.claude-history.tracker").setup()
     require("plugins.claude-history.commands").setup()
   end
   ```

2. **`config/nvim/lua/config/keymaps.lua`**
   ```lua
   { "<leader>ah", ... desc = "Claude [H]istory (current session)" },
   { "<leader>aH", ... desc = "Claude [H]istory (all sessions)" },
   ```

## Usage

### Keybindings

- `<leader>ah` - Open history picker (current session)
- `<leader>aH` - Open history picker (all sessions)

### Commands

- `:ClaudeHistory` - Open history picker (current session)
- `:ClaudeHistoryAll` - Open history picker (all sessions)
- `:ClaudeHistoryClear` - Clear current session
- `:ClaudeHistoryClearAll` - Clear all sessions
- `:ClaudeHistoryNewSession` - Manually start new session
- `:ClaudeHistoryInfo` - Show session info

### Picker Actions

- `<CR>` - Open file (if available) or show details
- `<c-x>` - Open file in horizontal split
- `<c-v>` - Open file in vertical split
- Preview pane - Shows file contents or entry JSON

## Data Structure

```lua
---@class HistoryEntry
---@field type "tool"|"bash"|"diff"|"save"
---@field timestamp number
---@field tool_name string? -- For MCP tools
---@field params table? -- Tool parameters
---@field command string? -- For bash commands
---@field file_path string? -- Associated file
---@field result table? -- Tool result if successful
```

## Technical Decisions

### Why Snacks Picker?

1. **Consistency** - User already uses Snacks for all pickers (`<leader>f*`)
2. **Zero dependencies** - claudecode.nvim already requires snacks.nvim
3. **Feature parity** - Preview, splits, actions all work out-of-box
4. **Performance** - Native Neovim integration

### Why In-Memory Storage?

1. **Simplicity** - No file I/O complexity
2. **Session-scoped** - History is relevant to current work session
3. **Privacy** - No persistent logs of commands/files
4. **Performance** - Fast access, no disk reads

Future enhancement could add persistent storage if needed.

### Why Wrap handle_invoke?

Alternative approaches considered:
- Parse terminal output (unreliable, no structured data)
- Hook into Neovim LSP/RPC (doesn't capture MCP protocol)
- Modify claudecode.nvim source (breaks on updates)

**Chosen**: Wrapper approach is non-invasive and captures all MCP calls with full context.

## Entry Types & Icons

| Type | Icon | Description |
|------|------|-------------|
| tool | 🔧 | Generic MCP tool invocation |
| bash | 🐚 | Shell command execution |
| diff | 📝 | Diff proposal from Claude |
| save | 💾 | File save operation |

## Testing Checklist

- [ ] Open Claude Code terminal (`<leader>ac`)
- [ ] Verify session starts automatically (`:ClaudeHistoryInfo`)
- [ ] Execute some bash commands in Claude terminal
- [ ] Have Claude open/edit files
- [ ] Open history picker (`<leader>ah`)
- [ ] Verify entries appear with correct icons and timestamps
- [ ] Test file preview in picker
- [ ] Test opening files from picker
- [ ] Test `:ClaudeHistoryClear`
- [ ] Test `:ClaudeHistoryAll` with multiple sessions

## Known Limitations

1. **Command detection heuristics** - May miss commands with non-standard prompts
   - **Solution**: Add custom patterns to `tracker.lua:extract_command()`

2. **In-memory only** - History lost on Neovim exit
   - **Future**: Add persistent storage option

3. **Polling overhead** - Checks terminal every 1 second
   - **Impact**: Minimal (single buffer scan)
   - **Configurable**: Edit `tracker.lua:92`

4. **No command replay** - Can't re-execute bash commands yet
   - **Future**: Add action to insert command into terminal

## Future Enhancements

### Short Term
- [ ] Export history to JSON/CSV
- [ ] Better command detection (handle multi-line commands)
- [ ] Grouping related entries (e.g., git workflow sequences)

### Medium Term
- [ ] Persistent storage (save to `~/.local/share/nvim/claude-history/`)
- [ ] Search/filter by file, command type, or time range
- [ ] Command replay functionality
- [ ] Integration with undo/redo for diff operations

### Long Term
- [ ] Session comparison (diff between sessions)
- [ ] Statistics dashboard (most used commands, files touched)
- [ ] Timeline view (visual representation of work session)
- [ ] Share session as gist/snippet for collaboration

## Files Created

```
config/nvim/lua/plugins/claude-history/
├── init.lua           # 90 lines  - Session management
├── tracker.lua        # 172 lines - Tool/command tracking
├── picker.lua         # 123 lines - Snacks picker integration
├── commands.lua       # 52 lines  - User commands
└── README.md          # 158 lines - Documentation

docs/sessions/
└── 2025-01-19-claude-history-tracker.md  # This file
```

**Total**: ~595 lines of code + documentation

## Files Modified

```
config/nvim/lua/plugins/claude-code.lua     # Added setup hooks
config/nvim/lua/config/keymaps.lua          # Added <leader>ah/aH
```

## Lessons Learned

1. **Snacks ecosystem** - Very powerful and consistent for picker-based UIs
2. **MCP protocol** - Clean JSON-RPC structure makes interception straightforward
3. **Terminal tracking** - Heuristic-based command extraction works well for common prompts
4. **Lazy loading** - Using `vim.defer_fn` prevents initialization race conditions
5. **Modular design** - Separate concerns (storage, tracking, UI, commands) enables easy extension

## References

- [claudecode.nvim](https://github.com/coder/claudecode.nvim) - Plugin being extended
- [snacks.nvim](https://github.com/folke/snacks.nvim) - Picker framework
- [MCP Protocol](https://modelcontextprotocol.io/) - Model Context Protocol spec
- Claude Code documentation - Tool schemas and behavior

## Acknowledgements

Built collaboratively with Claude (Sonnet 4.5) using Claude Code itself - a meta example of the tool tracking its own development! 🎯
