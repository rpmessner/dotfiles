-- Multi-pane UI for Claude Code history
local M = {}

local history = require("claude-history")

---@class ClaudeHistoryUI
---@field layout snacks.layout
---@field sessions_buf number
---@field entries_buf number
---@field diff_buf number
---@field sessions table
---@field current_session_idx number
---@field entries table
---@field current_entry_idx number

---Format timestamp as HH:MM:SS
---@param timestamp number
---@return string
local function format_time(timestamp)
  return os.date("%H:%M:%S", timestamp)
end

---Get icon for entry type
---@param entry_type string
---@return string
local function get_icon(entry_type)
  local icons = {
    tool = "🔧",
    bash = "🐚",
    diff = "📝",
    save = "💾",
  }
  return icons[entry_type] or "📋"
end

---Format history entry for display
---@param entry HistoryEntry
---@return string
local function format_entry(entry)
  local time = format_time(entry.timestamp or os.time())
  local icon = get_icon(entry.type)

  if entry.type == "bash" then
    return string.format("[%s] %s %s", time, icon, entry.command or "unknown")
  elseif entry.type == "tool" then
    local detail = entry.tool_name or "unknown"
    if entry.file_path then
      detail = detail .. " → " .. vim.fn.fnamemodify(entry.file_path, ":~:.")
    end
    return string.format("[%s] %s Tool: %s", time, icon, detail)
  elseif entry.type == "diff" then
    local file = entry.file_path and vim.fn.fnamemodify(entry.file_path, ":~:.") or "unknown"
    return string.format("[%s] %s Diff: %s", time, icon, file)
  elseif entry.type == "save" then
    local file = entry.file_path and vim.fn.fnamemodify(entry.file_path, ":~:.") or "unknown"
    return string.format("[%s] %s Save: %s", time, icon, file)
  end

  return string.format("[%s] %s %s", time, icon, entry.type or "unknown")
end

---Create a scratch buffer with custom options
---@param name string
---@return number
local function create_scratch_buffer(name)
  -- Check if buffer with this name already exists and delete it
  local existing_buf = vim.fn.bufnr(name)
  if existing_buf ~= -1 and vim.api.nvim_buf_is_valid(existing_buf) then
    vim.api.nvim_buf_delete(existing_buf, { force = true })
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, name)
  vim.api.nvim_set_option_value("buftype", "nofile", { buf = buf })
  vim.api.nvim_set_option_value("bufhidden", "wipe", { buf = buf })
  vim.api.nvim_set_option_value("swapfile", false, { buf = buf })
  vim.api.nvim_set_option_value("modifiable", true, { buf = buf })
  return buf
end

---Populate sessions buffer
---@param ui ClaudeHistoryUI
local function populate_sessions(ui)
  local sessions_data = history.get_sessions()
  ui.sessions = {}

  local lines = {}
  for i, session in ipairs(sessions_data) do
    table.insert(ui.sessions, session)
    local entry_count = #session.entries
    local time = format_time(session.start_time)
    table.insert(lines, string.format("Session %d [%s] (%d entries)", i, time, entry_count))
  end

  if #lines == 0 then
    lines = { "No sessions available" }
  end

  vim.api.nvim_buf_set_lines(ui.sessions_buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = ui.sessions_buf })
end

---Populate entries buffer for selected session
---@param ui ClaudeHistoryUI
local function populate_entries(ui)
  if not ui.current_session_idx or ui.current_session_idx < 1 or ui.current_session_idx > #ui.sessions then
    vim.api.nvim_buf_set_lines(ui.entries_buf, 0, -1, false, { "Select a session" })
    vim.api.nvim_set_option_value("modifiable", false, { buf = ui.entries_buf })
    return
  end

  local session = ui.sessions[ui.current_session_idx]
  ui.entries = session.entries or {}

  local lines = {}
  for _, entry in ipairs(ui.entries) do
    table.insert(lines, format_entry(entry))
  end

  if #lines == 0 then
    lines = { "No entries in this session" }
  end

  vim.api.nvim_buf_set_lines(ui.entries_buf, 0, -1, false, lines)
  vim.api.nvim_set_option_value("modifiable", false, { buf = ui.entries_buf })
end

---Update diff preview based on current entry
---@param ui ClaudeHistoryUI
local function update_diff_preview(ui)
  if not ui.current_entry_idx or ui.current_entry_idx < 1 or ui.current_entry_idx > #ui.entries then
    vim.api.nvim_buf_set_lines(ui.diff_buf, 0, -1, false, { "No preview available" })
    return
  end

  local entry = ui.entries[ui.current_entry_idx]

  -- For diff entries, show side-by-side comparison
  if entry.type == "diff" and entry.old_file_contents and entry.new_file_contents then
    local old_lines = vim.split(entry.old_file_contents, "\n")
    local new_lines = vim.split(entry.new_file_contents, "\n")

    -- Simple side-by-side display
    local lines = { "=== Diff Preview ===" }
    table.insert(lines, "OLD | NEW")
    table.insert(lines, string.rep("-", 80))

    local max_lines = math.max(#old_lines, #new_lines)
    for i = 1, math.min(max_lines, 50) do -- Limit to 50 lines for preview
      local old_line = old_lines[i] or ""
      local new_line = new_lines[i] or ""
      table.insert(lines, string.format("%-38s | %s", old_line:sub(1, 38), new_line:sub(1, 38)))
    end

    if max_lines > 50 then
      table.insert(lines, "... (truncated)")
    end

    vim.api.nvim_buf_set_lines(ui.diff_buf, 0, -1, false, lines)
  elseif entry.type == "bash" then
    -- Show command details
    local lines = {
      "=== Bash Command ===",
      "",
      entry.command or "unknown command",
      "",
      "Time: " .. format_time(entry.timestamp or os.time()),
    }
    vim.api.nvim_buf_set_lines(ui.diff_buf, 0, -1, false, lines)
  elseif entry.file_path then
    -- Show file preview
    local file_path = vim.fn.expand(entry.file_path)
    if vim.fn.filereadable(file_path) == 1 then
      local file_lines = vim.fn.readfile(file_path, "", 50) -- First 50 lines
      table.insert(file_lines, 1, "=== File: " .. vim.fn.fnamemodify(file_path, ":~:.") .. " ===")
      table.insert(file_lines, 2, "")
      vim.api.nvim_buf_set_lines(ui.diff_buf, 0, -1, false, file_lines)

      -- Set filetype for syntax highlighting
      local ft = vim.filetype.match({ filename = file_path }) or ""
      if ft ~= "" then
        vim.api.nvim_set_option_value("filetype", ft, { buf = ui.diff_buf })
      end
    else
      vim.api.nvim_buf_set_lines(ui.diff_buf, 0, -1, false, { "File not found: " .. file_path })
    end
  else
    -- Show entry details as JSON
    local details = vim.json.encode(entry, { indent = true })
    local lines = vim.split(details, "\n")
    vim.api.nvim_buf_set_lines(ui.diff_buf, 0, -1, false, lines)
    vim.api.nvim_set_option_value("filetype", "json", { buf = ui.diff_buf })
  end
end

---Setup keybindings for a buffer
---@param ui ClaudeHistoryUI
---@param buf number
---@param is_sessions boolean
local function setup_keybindings(ui, buf, is_sessions)
  local opts = { buffer = buf, noremap = true, silent = true }

  -- Close the UI
  vim.keymap.set("n", "q", function()
    ui.layout:close()
  end, opts)

  vim.keymap.set("n", "<Esc>", function()
    ui.layout:close()
  end, opts)

  -- <C-j> to move to entries pane (works from both panes)
  vim.keymap.set("n", "<C-j>", function()
    local entries_win = ui.layout.wins.entries
    if entries_win and entries_win.win and vim.api.nvim_win_is_valid(entries_win.win) then
      vim.api.nvim_set_current_win(entries_win.win)
    end
  end, opts)

  -- <C-k> to move to sessions pane (works from both panes)
  vim.keymap.set("n", "<C-k>", function()
    local sessions_win = ui.layout.wins.sessions
    if sessions_win and sessions_win.win and vim.api.nvim_win_is_valid(sessions_win.win) then
      vim.api.nvim_set_current_win(sessions_win.win)
    end
  end, opts)

  if is_sessions then
    -- Session list keybindings
    vim.keymap.set("n", "<CR>", function()
      local line = vim.api.nvim_win_get_cursor(0)[1]
      ui.current_session_idx = line
      ui.current_entry_idx = 1
      populate_entries(ui)
      update_diff_preview(ui)

      -- Move cursor to entries buffer
      local entries_win = ui.layout.wins.entries
      if entries_win and entries_win.win and vim.api.nvim_win_is_valid(entries_win.win) then
        vim.api.nvim_set_current_win(entries_win.win)
      end
    end, opts)
  else
    -- Entries list keybindings - update preview on cursor move
    vim.keymap.set("n", "j", function()
      vim.cmd("normal! j")
      ui.current_entry_idx = vim.api.nvim_win_get_cursor(0)[1]
      update_diff_preview(ui)
    end, opts)

    vim.keymap.set("n", "k", function()
      vim.cmd("normal! k")
      ui.current_entry_idx = vim.api.nvim_win_get_cursor(0)[1]
      update_diff_preview(ui)
    end, opts)

    vim.keymap.set("n", "<Down>", function()
      vim.cmd("normal! j")
      ui.current_entry_idx = vim.api.nvim_win_get_cursor(0)[1]
      update_diff_preview(ui)
    end, opts)

    vim.keymap.set("n", "<Up>", function()
      vim.cmd("normal! k")
      ui.current_entry_idx = vim.api.nvim_win_get_cursor(0)[1]
      update_diff_preview(ui)
    end, opts)

    -- Enter in entries pane: context-aware behavior
    vim.keymap.set("n", "<CR>", function()
      if not ui.current_entry_idx or ui.current_entry_idx > #ui.entries then
        return
      end

      local entry = ui.entries[ui.current_entry_idx]

      -- For bash commands: move back to sessions pane
      if entry.type == "bash" then
        local sessions_win = ui.layout.wins.sessions
        if sessions_win and sessions_win.win and vim.api.nvim_win_is_valid(sessions_win.win) then
          vim.api.nvim_set_current_win(sessions_win.win)
        end
        return
      end

      -- For file changes: open the file/diff
      if entry.type == "diff" and entry.old_file_contents and entry.new_file_contents then
        -- Close the UI and open full diff
        ui.layout:close()

        -- Create two scratch buffers for the diff
        local old_buf = vim.api.nvim_create_buf(false, true)
        local new_buf = vim.api.nvim_create_buf(false, true)

        vim.api.nvim_buf_set_lines(old_buf, 0, -1, false, vim.split(entry.old_file_contents, "\n"))
        vim.api.nvim_buf_set_lines(new_buf, 0, -1, false, vim.split(entry.new_file_contents, "\n"))

        local filename = vim.fn.fnamemodify(entry.file_path or "unknown", ":t")
        vim.api.nvim_buf_set_name(old_buf, "OLD: " .. filename)
        vim.api.nvim_buf_set_name(new_buf, "NEW: " .. filename)

        local ft = vim.filetype.match({ filename = entry.file_path }) or ""
        vim.api.nvim_set_option_value("filetype", ft, { buf = old_buf })
        vim.api.nvim_set_option_value("filetype", ft, { buf = new_buf })

        vim.cmd("tabnew")
        vim.cmd("buffer " .. old_buf)
        vim.cmd("diffthis")
        vim.cmd("vsplit")
        vim.cmd("buffer " .. new_buf)
        vim.cmd("diffthis")
      elseif entry.file_path then
        -- Open file
        ui.layout:close()
        local file_path = vim.fn.expand(entry.file_path)
        if vim.fn.filereadable(file_path) == 1 then
          vim.cmd("edit " .. vim.fn.fnameescape(file_path))
        else
          vim.notify("File not found: " .. file_path, vim.log.levels.WARN)
        end
      end
    end, opts)
  end
end

---Open history UI
---@param opts table?
function M.open(opts)
  opts = opts or {}

  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("Snacks.nvim not available", vim.log.levels.ERROR)
    return
  end

  ---@type ClaudeHistoryUI
  local ui = {
    sessions = {},
    entries = {},
    current_session_idx = 1,
    current_entry_idx = 1,
  }

  -- Create buffers
  ui.sessions_buf = create_scratch_buffer("claude-history-sessions")
  ui.entries_buf = create_scratch_buffer("claude-history-entries")
  ui.diff_buf = create_scratch_buffer("claude-history-diff")

  -- Populate initial data
  populate_sessions(ui)

  -- Create layout
  ui.layout = snacks.layout.new({
    wins = {
      sessions = {
        buf = ui.sessions_buf,
        title = " Sessions ",
        title_pos = "center",
      },
      entries = {
        buf = ui.entries_buf,
        title = " Commands & Edits ",
        title_pos = "center",
      },
      diff = {
        buf = ui.diff_buf,
        title = " Preview ",
        title_pos = "center",
      },
    },
    layout = {
      box = "vertical",
      width = 0.9,
      height = 0.9,
      {
        box = "horizontal",
        height = 0.6,
        {
          win = "sessions",
          width = 0.3,
          border = true,
        },
        {
          win = "entries",
          width = 0.7,
          border = true,
        },
      },
      {
        win = "diff",
        height = 0.4,
        border = true,
      },
    },
  })

  -- Setup keybindings
  setup_keybindings(ui, ui.sessions_buf, true)
  setup_keybindings(ui, ui.entries_buf, false)

  -- Set cursor to sessions buffer
  local sessions_win = ui.layout.wins.sessions
  if sessions_win and sessions_win.win and vim.api.nvim_win_is_valid(sessions_win.win) then
    vim.api.nvim_set_current_win(sessions_win.win)
  end

  -- Load first session by default
  if #ui.sessions > 0 then
    populate_entries(ui)
    update_diff_preview(ui)
  end
end

return M
