-- lazydev.nvim - Proper Lua LSP setup for Neovim config development
-- Provides excellent vim.* API completions without manual setup
return {
  "folke/lazydev.nvim",
  ft = "lua", -- only load on lua files
  opts = {
    library = {
      -- Load luvit types when the `vim.uv` word is found
      { path = "luvit-meta/library", words = { "vim%.uv" } },
      -- Load the LazyVim library when the `LazyVim` word is found (if you use LazyVim)
      -- { path = "LazyVim", words = { "LazyVim" } },
    },
  },
  dependencies = {
    -- optional `vim.uv` typings
    { "Bilal2453/luvit-meta", lazy = true },
  },
}
