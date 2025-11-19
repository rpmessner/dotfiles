-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    -- bg = "#16161e"
    -- bg = "#1a1b26"
    -- bg = "#0C0E14"
    --
    -- Create highlight that matches background (invisible borders)
    -- vim.api.nvim_set_hl(0, "SnacksPickerBorder", { fg = bg, bg = bg })
    -- vim.api.nvim_set_hl(0, "SnacksPickerPreviewBorder", { fg = bg, bg = bg })
    -- vim.api.nvim_set_hl(0, "SnacksPickerListBorder", { fg = bg, bg = bg })
    -- vim.api.nvim_set_hl(0, "SnacksPickerInputBorder", { fg = bg, bg = bg })
  end,
})

-- Markdown settings: enable line wrapping and soft wrapping at word boundaries
vim.api.nvim_create_autocmd("FileType", {
  pattern = "markdown",
  callback = function()
    vim.opt_local.wrap = true -- Enable line wrapping
    vim.opt_local.linebreak = true -- Wrap at word boundaries (don't break words)
    vim.opt_local.breakindent = true -- Preserve indentation in wrapped lines
  end,
})
