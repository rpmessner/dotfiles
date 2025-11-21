-- conform.nvim - Modern async formatting
-- Replaces null-ls which is no longer maintained
local keymaps = require("config.keymaps")

return {
  "stevearc/conform.nvim",
  event = { "BufWritePre" },
  cmd = { "ConformInfo" },
  keys = keymaps.conform_mappings,
  opts = {
    -- Define your formatters
    formatters_by_ft = {
      lua = { "stylua" },
      -- sh/bash/zsh
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      -- web
      javascript = { "prettier" },
      typescript = { "prettier" },
      javascriptreact = { "prettier" },
      typescriptreact = { "prettier" },
      css = { "prettier" },
      html = { "prettier" },
      json = { "prettier" },
      jsonc = { "prettier" },
      yaml = { "prettier" },
      -- markdown linting handled by markdownlint-cli2 via nvim-lint
      -- markdown = { "prettier" },
      -- elixir
      elixir = { "mix" },
      -- python
      python = { "ruff_format", "ruff_fix" },
      -- rust
      rust = { "rustfmt" },
      -- go
      go = { "gofmt", "goimports" },
      -- ruby
      ruby = { "rubocop" },
      eruby = { "erb_format" },
      -- toml
      toml = { "taplo" },
      -- terraform
      terraform = { "terraform_fmt" },
      hcl = { "terraform_fmt" },
    },
    -- Set default formatting options
    default_format_opts = {
      lsp_format = "fallback",
    },
    -- Format on save (can disable by setting format_on_save = false)
    format_on_save = {
      -- These options will be passed to conform.format()
      timeout_ms = 500,
      lsp_fallback = true,
    },
    -- Customize formatters
    formatters = {
      shfmt = {
        prepend_args = { "-i", "2", "-ci", "-bn", "-s" },
      },
    },
  },
}
