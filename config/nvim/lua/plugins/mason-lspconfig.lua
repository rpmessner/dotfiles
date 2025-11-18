return {
  "mason-org/mason-lspconfig.nvim",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = {
    "mason-org/mason.nvim",
    -- Collection of configurations for the built-in LSP client
    {
      "neovim/nvim-lspconfig",

      -- blink is needed for setting up capabilities in core.lsp
      dependencies = { "saghen/blink.cmp" },
    },
  },
  opts = {
    ensure_installed = {
      "clangd",
    },
  },
  config = function(_self, opts)
    require("config.lsp").setup()
    require("mason-lspconfig").setup(opts)
  end,
}
