-- Override LazyVim's lang.markdown extra to disable prosemd-lsp
-- prosemd-lsp provides prose linting but has no configuration options
-- and gives annoying serial comma and m-dash warnings with no way to disable them
return {
  -- Keep marksman (markdown LSP) enabled
  {
    "artempyanykh/marksman",
    ft = "markdown",
  },
  -- Explicitly disable prosemd-lsp from LazyVim's markdown extra
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        prosemd_lsp = {
          -- Disable entirely
          mason = false,
          enabled = false,
        },
      },
    },
  },
}
