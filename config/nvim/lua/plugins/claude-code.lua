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
  dependencies = { "folke/snacks.nvim" },
  config = function()
    require("claudecode").setup()

    -- Setup history tracking
    require("plugins.claude-history.tracker").setup()

    -- Setup history commands
    require("plugins.claude-history.commands").setup()
  end,
  keys = keymaps.claude_code_mappings,
}
