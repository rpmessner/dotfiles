-- Disable LazyVim defaults that conflict with our custom plugins
-- This file explicitly overrides LazyVim's built-in plugin configurations
return {
  -- Using blink-cmp instead of nvim-cmp
  { "hrsh7th/nvim-cmp", enabled = false },
  { "hrsh7th/cmp-nvim-lsp", enabled = false },
  { "hrsh7th/cmp-buffer", enabled = false },
  { "hrsh7th/cmp-path", enabled = false },

  -- Using snacks.picker instead of telescope
  { "nvim-telescope/telescope.nvim", enabled = false },

  -- Using oil.nvim instead of neo-tree
  { "nvim-neo-tree/neo-tree.nvim", enabled = false },
}
