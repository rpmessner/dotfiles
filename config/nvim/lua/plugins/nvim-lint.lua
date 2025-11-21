-- nvim-lint - Async linting for Neovim
-- Provides linting via external tools
return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    -- Override LazyVim's default markdown linter with our configured one
    opts.linters_by_ft = opts.linters_by_ft or {}
    opts.linters_by_ft.markdown = { "markdownlint-cli2" }
    opts.linters_by_ft.ruby = { "rubocop" }
    opts.linters_by_ft.eruby = { "erb_lint" }
    opts.linters_by_ft.elixir = { "credo" }

    -- Configure markdownlint-cli2 to use our config
    opts.linters = opts.linters or {}
    opts.linters["markdownlint-cli2"] = {
      args = {
        "--config",
        vim.fn.expand("~/.markdownlint.jsonc"),
      },
    }

    return opts
  end,
}
