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
    local session_id = history.current_session_id or "none"
    local msg = string.format("Session ID: %s\nEntries: %d", session_id, #entries)
    vim.notify(msg, vim.log.levels.INFO, { title = "Claude Code History" })
  end, {
    desc = "Show Claude Code history session info",
  })

  -- Seed test data (for testing the viewer)
  vim.api.nvim_create_user_command("ClaudeHistorySeed", function()
    -- Start a session if needed
    history.get_or_create_session()

    -- Add test entries simulating what would be captured
    local cwd = vim.fn.getcwd()
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

    local count = #history.get_current_entries()
    vim.notify(string.format("Seeded %d test entries", count), vim.log.levels.INFO)
  end, {
    desc = "Seed test data for Claude Code history",
  })
end

return M
