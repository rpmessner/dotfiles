-- nvim-lint - Async linting for Neovim
-- Provides linting via external tools
return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    -- Configure linters by filetype
    linters_by_ft = {
      markdown = { "markdownlint-cli2" },
      ruby = { "rubocop" },
      eruby = { "erb_lint" },
      elixir = { "credo" },
    },
  },
}
