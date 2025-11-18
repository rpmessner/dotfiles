-- hardtime.nvim - Break bad vim habits
-- Prevents inefficient patterns and teaches better motions
return {
  "m4xshen/hardtime.nvim",
  dependencies = { "MunifTanjim/nui.nvim" },
  event = "VeryLazy",
  opts = {
    -- Maximum number of repetitive key presses allowed
    max_count = 3,
    -- Disable arrow keys in normal mode
    disable_mouse = false,
    -- Hint message when you trigger a restriction
    hint = true,
    -- Show notification when restricted
    notification = true,
    -- Allow different keys in between (e.g., "jjkj" would be allowed)
    allow_different_key = true,
    -- Enabled by default, set to false to disable on startup
    enabled = true,
    -- Keys to restrict (blocks repeated usage beyond max_count)
    restriction_mode = "block", -- "block" or "hint"
    -- List of keys to restrict
    restricted_keys = {
      ["h"] = { "n", "x" },
      ["j"] = { "n", "x" },
      ["k"] = { "n", "x" },
      ["l"] = { "n", "x" },
      ["-"] = { "n", "x" },
      ["+"] = { "n", "x" },
      ["gj"] = { "n", "x" },
      ["gk"] = { "n", "x" },
      ["<CR>"] = { "n", "x" },
      ["<C-M>"] = { "n", "x" },
      ["<C-N>"] = { "n", "x" },
      ["<C-P>"] = { "n", "x" },
    },
    -- Disable hardtime in certain filetypes
    disabled_filetypes = {
      "qf",
      "netrw",
      "NvimTree",
      "lazy",
      "mason",
      "oil",
      "snacks_dashboard",
    },
  },
  keys = require("config.keymaps").hardtime_mappings,
}
