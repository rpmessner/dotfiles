-- Override LazyVim's treesitter configuration
-- Fix for Neovim nightly 0.12.0-dev compatibility issues
return {
  "nvim-treesitter/nvim-treesitter",
  version = false, -- Use latest git commit for nightly compatibility
  build = ":TSUpdate",
  opts = function(_, opts)
    -- Force reinstall of parsers for nightly compatibility
    opts.auto_install = true
    opts.sync_install = false

    -- Ensure core parsers are installed
    opts.ensure_installed = opts.ensure_installed or {}
    vim.list_extend(opts.ensure_installed, {
      "lua",
      "vim",
      "vimdoc",
      "query",
      "markdown",
      "markdown_inline",
    })

    -- Disable problematic features temporarily
    opts.highlight = opts.highlight or {}
    opts.highlight.enable = true
    opts.highlight.additional_vim_regex_highlighting = false

    return opts
  end,
}
