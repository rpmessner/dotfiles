-- Improved jumplist experience with preview
---@type LazySpec
return {
  "cbochs/portal.nvim",
  keys = {
    { "[j", "<cmd>Portal jumplist backward<cr>", desc = "portal backward" },
    { "]j", "<cmd>Portal jumplist forward<cr>", desc = "portal forward" },
  },
  opts = {},
}
