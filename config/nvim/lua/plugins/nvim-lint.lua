-- nvim-lint - Async linting for Neovim
-- Provides linting via external tools
return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    -- Override/merge linters by filetype
    opts.linters_by_ft = opts.linters_by_ft or {}
    opts.linters_by_ft.markdown = { "markdownlint-cli2" }
    opts.linters_by_ft.ruby = { "rubocop" }
    opts.linters_by_ft.eruby = { "erb_lint" }
    opts.linters_by_ft.elixir = { "credo" }

    -- Ensure markdownlint-cli2 uses config from home directory
    opts.linters = opts.linters or {}
    opts.linters["markdownlint-cli2"] = {
      -- markdownlint-cli2 automatically discovers .markdownlint-cli2.jsonc
      -- and .markdownlint.jsonc from cwd upward to home directory
      args = {},
    }

    return opts
  end,
}
