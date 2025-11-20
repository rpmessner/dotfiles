-- User commands for Claude Code history
local M = {}

local history = require("plugins.claude-history")
local picker = require("plugins.claude-history.picker")

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
end

return M
