---@type LazySpec
return {
  "folke/flash.nvim",
  -- event = 'VeryLazy',
  ---@module "flash"
  ---@type Flash.Config
  opts = {
    modes = {
      char = {
        enabled = true,
        jump_labels = true,
        highlight = { backdrop = false },
      },
    },
    label = {
      rainbow = {
        enabled = true,
        shade = 5,
      },
    },
    highlight = {
      backdrop = false,
    },
  },
  keys = require("config.keymaps").flash_mappings,
}
