-- RipGrep - grep is dead. All hail the new king RipGrep.
---@type LazySpec
return {
  "jremmen/vim-ripgrep",
  cmd = "Rg",
  init = function()
    -- allow hidden files to be searched and smart case
    vim.g.rg_command = "rg --vimgrep --hidden --smart-case"
    vim.g.rg_highlight = 1
  end,
  keys = {
    --  alias for above
    --  Grep project for selection with Rg
    { "<leader>rg", 'y :Rg "<CR>', mode = "v", desc = "[R]ip[G]rep selection" },
    --  Grep project for word under the cursor with Rg
    { "<Leader>rg", ":Rg <C-r><C-w><CR>", desc = "[R]ip[G]rep word under cursor" },
  },
}
