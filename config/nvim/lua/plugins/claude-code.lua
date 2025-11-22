-- return {
--   "greggh/claude-code.nvim",
--   dependencies = {
--     "nvim-lua/plenary.nvim", -- Required for git operations
--   },
--   config = function()
--     require("claude-code").setup()
--   end,
-- }
local keymaps = require("config.keymaps")

return {
  "coder/claudecode.nvim",
  dependencies = {
    "folke/snacks.nvim",
    -- Claude Code history tracker (refactored to separate plugin)
    {
      dir = "~/dev/utils/claude-history.nvim",
      lazy = false,
    },
  },
  config = function()
    require("claudecode").setup()
    -- Note: claude-history.nvim auto-loads via plugin/claude-history.lua
  end,
  keys = keymaps.claude_code_mappings,
}
