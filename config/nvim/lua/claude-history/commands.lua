-- User commands for Claude Code history
local M = {}

local history = require("claude-history")
local picker = require("claude-history.picker")

function M.setup()
  -- Open history picker (current session)
  vim.api.nvim_create_user_command("ClaudeHistory", function()
    picker.open()
  end, {
    desc = "Open Claude Code history picker (current session)",
  })

  -- Open history picker (all sessions)
  vim.api.nvim_create_user_command("ClaudeHistoryAll", function()
    picker.open({ all = true })
  end, {
    desc = "Open Claude Code history picker (all sessions)",
  })

  -- Clear current session
  vim.api.nvim_create_user_command("ClaudeHistoryClear", function()
    history.clear_current_session()
    vim.notify("Claude Code history cleared (current session)", vim.log.levels.INFO)
  end, {
    desc = "Clear Claude Code history (current session)",
  })

  -- Clear all sessions
  vim.api.nvim_create_user_command("ClaudeHistoryClearAll", function()
    history.clear_all_sessions()
    vim.notify("Claude Code history cleared (all sessions)", vim.log.levels.INFO)
  end, {
    desc = "Clear Claude Code history (all sessions)",
  })

  -- Start new session
  vim.api.nvim_create_user_command("ClaudeHistoryNewSession", function()
    local session_id = history.start_session()
    vim.notify("Started new Claude Code session: " .. session_id, vim.log.levels.INFO)
  end, {
    desc = "Start a new Claude Code history session",
  })

  -- Show session info
  vim.api.nvim_create_user_command("ClaudeHistoryInfo", function()
    local entries = history.get_current_entries()
    local sessions = history.get_sessions()
    local session_id = history.current_session_id or "none"
    local cwd = history.current_cwd and vim.fn.fnamemodify(history.current_cwd, ":~") or "none"

    local msg = string.format(
      "Current Directory: %s\nCurrent Session: %s\nTotal Sessions: %d\nCurrent Entries: %d\n\nStorage: %s",
      cwd,
      session_id,
      #sessions,
      #entries,
      vim.fn.stdpath("data") .. "/claude-history/"
    )
    vim.notify(msg, vim.log.levels.INFO, { title = "Claude Code History" })
  end, {
    desc = "Show Claude Code history session info",
  })

  -- Seed test data (for testing the viewer)
  vim.api.nvim_create_user_command("ClaudeHistorySeed", function()
    -- Initialize history for current directory if not already
    local cwd = vim.fn.getcwd()
    if not history.current_cwd then
      history.init(cwd)
    end

    -- Create multiple sessions for testing
    -- Session 1 (oldest)
    history.start_session()
    history.add_entry({
      type = "tool",
      tool_name = "open_file",
      file_path = cwd .. "/config/nvim/lua/plugins/claude-code.lua",
      params = { filePath = cwd .. "/config/nvim/lua/plugins/claude-code.lua" },
      timestamp = os.time() - 300,
    })

    vim.wait(50)
    history.add_entry({
      type = "bash",
      command = "git status",
      timestamp = os.time() - 250,
    })

    vim.wait(50)
    history.add_entry({
      type = "tool",
      tool_name = "get_diagnostics",
      params = {},
      timestamp = os.time() - 200,
    })

    vim.wait(50)
    -- Add a realistic diff entry with actual content
    local old_content = [[local M = {}

function M.hello()
  print("Hello, World!")
end

return M]]

    local new_content = [[local M = {}

function M.hello()
  print("Hello, Claude!")
  print("This is a new line")
end

function M.goodbye()
  print("Goodbye!")
end

return M]]

    history.add_entry({
      type = "diff",
      tool_name = "openDiff",
      file_path = cwd .. "/config/nvim/lua/claude-history/tracker.lua",
      old_file_path = cwd .. "/config/nvim/lua/claude-history/tracker.lua",
      new_file_path = cwd .. "/config/nvim/lua/claude-history/tracker.lua",
      old_file_contents = old_content,
      new_file_contents = new_content,
      tab_name = "Update tracker",
      params = {
        old_file_path = cwd .. "/config/nvim/lua/claude-history/tracker.lua",
        new_file_contents = new_content,
      },
      timestamp = os.time() - 150,
    })

    vim.wait(50)
    history.add_entry({
      type = "bash",
      command = "task -l",
      timestamp = os.time() - 100,
    })

    vim.wait(50)
    history.add_entry({
      type = "save",
      tool_name = "save_document",
      file_path = cwd .. "/config/nvim/lua/claude-history/commands.lua",
      params = { filePath = cwd .. "/config/nvim/lua/claude-history/commands.lua" },
      timestamp = os.time() - 50,
    })

    -- Session 2 (recent)
    history.start_session()
    history.add_entry({
      type = "bash",
      command = "git diff HEAD~1",
      timestamp = os.time() - 50,
    })
    history.add_entry({
      type = "tool",
      tool_name = "Grep",
      params = { pattern = "function", glob = "*.lua" },
      timestamp = os.time() - 30,
    })

    -- Session 3 (most recent)
    history.start_session()
    history.add_entry({
      type = "bash",
      command = "fd -t f '.lua' config/nvim",
      timestamp = os.time() - 10,
    })

    local total_sessions = #history.get_sessions()
    local total_entries = 0
    for _, session in ipairs(history.get_sessions()) do
      total_entries = total_entries + #session.entries
    end
    vim.notify(
      string.format("Seeded %d sessions with %d total entries", total_sessions, total_entries),
      vim.log.levels.INFO
    )
  end, {
    desc = "Seed test data for Claude Code history",
  })
end

return M
