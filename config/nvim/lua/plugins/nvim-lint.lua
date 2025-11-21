-- nvim-lint - Async linting for Neovim
-- Provides linting via external tools
return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = function(_, opts)
    -- Override/merge linters by filetype
    -- Force only markdownlint-cli2 for markdown (LazyVim might add others)
    opts.linters_by_ft = opts.linters_by_ft or {}
    opts.linters_by_ft.markdown = { "markdownlint-cli2" }
    opts.linters_by_ft.ruby = { "rubocop" }
    opts.linters_by_ft.eruby = { "erb_lint" }
    opts.linters_by_ft.elixir = { "credo" }

    -- Configure both markdownlint variants to use our config
    -- LazyVim's markdown extra might use either one
    opts.linters = opts.linters or {}
    local config_path = vim.fn.expand("~/.markdownlint.jsonc")

    opts.linters["markdownlint-cli2"] = {
      args = {
        "--config",
        config_path,
      },
    }

    -- Also configure regular markdownlint in case LazyVim uses it
    opts.linters["markdownlint"] = {
      args = {
        "--config",
        config_path,
      },
    }

    return opts
  end,
}
