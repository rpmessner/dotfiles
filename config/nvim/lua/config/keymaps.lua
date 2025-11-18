-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local utils = require("config.utils")

--[[
╭────────────────────────────────────────────────────────────────────────────╮
│  Str  │  Help page   │  Affected modes                           │  VimL   │
│────────────────────────────────────────────────────────────────────────────│
│  ''   │  mapmode-nvo │  Normal, Visual, Select, Operator-pending │  :map   │
│  'n'  │  mapmode-n   │  Normal                                   │  :nmap  │
│  'v'  │  mapmode-v   │  Visual and Select                        │  :vmap  │
│  's'  │  mapmode-s   │  Select                                   │  :smap  │
│  'x'  │  mapmode-x   │  Visual                                   │  :xmap  │
│  'o'  │  mapmode-o   │  Operator-pending                         │  :omap  │
│  '!'  │  mapmode-ic  │  Insert and Command-line                  │  :map!  │
│  'i'  │  mapmode-i   │  Insert                                   │  :imap  │
│  'l'  │  mapmode-l   │  Insert, Command-line, Lang-Arg           │  :lmap  │
│  'c'  │  mapmode-c   │  Command-line                             │  :cmap  │
│  't'  │  mapmode-t   │  Terminal                                 │  :tmap  │
╰────────────────────────────────────────────────────────────────────────────╯
--]]

local map = function(tbl)
  vim.keymap.set(tbl[1], tbl[2], tbl[3], tbl[4])
end

---@diagnostic disable-next-line: unused-local, unused-function
local imap = function(tbl)
  vim.keymap.set("i", tbl[1], tbl[2], tbl[3])
end

local nmap = function(tbl)
  vim.keymap.set("n", tbl[1], tbl[2], tbl[3])
end

local vmap = function(tbl)
  vim.keymap.set("v", tbl[1], tbl[2], tbl[3])
end

local tmap = function(tbl)
  vim.keymap.set("t", tbl[1], tbl[2], tbl[3])
end

---@diagnostic disable-next-line: unused-local, unused-function
local cmap = function(tbl)
  vim.keymap.set("c", tbl[1], tbl[2], tbl[3])
end

---Convenience shorthand for lazy calling picker
---@param fun string the picker function to use
---@param opts table? options to pass to the picker function
---@return function
local picker = function(fun, opts)
  if opts == nil then
    opts = {}
  end

  return function()
    Snacks.picker[fun](opts)
  end
end

---Convenience shorthand for calling tmux seamless navigator plugin
---@param fun string the function to call
---@return function
local tmux = function(fun)
  return function()
    require("tmux")[fun]()
  end
end

local silent = { silent = true }

-- AI assistant window navigation
-- Use <C-w>w or <C-w>h/l to navigate between code and AI windows
-- Use <C-w>o to close AI window and focus code
nmap({ "<leader>ww", "<C-w>w", { desc = "Cycle windows" } })
nmap({ "<leader>wh", "<C-w>h", { desc = "Move to left window" } })
nmap({ "<leader>wl", "<C-w>l", { desc = "Move to right window" } })

-- Create autocmd for AI-specific buffer keymaps
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "Avante", "AvanteInput", "claude-code" },
  callback = function(args)
    local bufnr = args.buf
    -- Override tmux navigation to allow scrolling in AI windows
    vim.keymap.set("n", "<C-j>", "5j", { buffer = bufnr, desc = "Scroll down in AI window" })
    vim.keymap.set("n", "<C-k>", "5k", { buffer = bufnr, desc = "Scroll up in AI window" })
    -- Keep horizontal navigation for switching to code
    vim.keymap.set("n", "<C-h>", "<C-w>h", { buffer = bufnr, desc = "Jump to left window" })
    vim.keymap.set("n", "<C-l>", "<C-w>l", { buffer = bufnr, desc = "Jump to right window" })
  end,
})

-- a more useful gf
nmap({ "gf", "gF", { desc = "Go to file under cursor", silent = true } })

-- center window on search result
nmap({ "n", "nzzzv" })
nmap({ "N", "Nzzzv" })

-- rename current file
nmap({ "<Leader>mv", ":Move <C-R>=expand('%')<CR>", { desc = "Move current file" } })

-- copy current file
nmap({ "<Leader>sa", ":saveas <C-R>=expand('%')<CR><Left><Left><Left>", { desc = "[S]ave [A]s current file" } })

-- remove highlighting on escape
nmap({ "<esc>", ":nohlsearch<cr>", silent })

nmap({ "<leader>ll", ":lua ", desc = "[L]aunch [L]ua" })

-- reload (current) lua file (does not reload module though...)
nmap({
  "<leader>rl",
  utils.reload_current_luafile,
  { desc = "Reload Current Lua File" },
})

-- replace word under cursor, globally, with confirmation
nmap({ "<Leader>k", [[:%s/\<<C-r><C-w>\>//gc<Left><Left><Left>]] })
vmap({ "<Leader>k", 'y :%s/<C-r>"//gc<Left><Left><Left>' })

-- qq to record (built-in), Q to replay
nmap({ "Q", "@q" })

-- Tab/shift-tab to indent/outdent in visual mode.
vmap({ "<Tab>", ">gv" })
vmap({ "<S-Tab>", "<gv" })

-- Keep selection when indenting/outdenting.
vmap({ ">", ">gv" })
vmap({ "<", "<gv" })

-- Search for selected text
vmap({ "*", '"xy/<C-R>x<CR>' })

--  Navigate neovim + tmux with ctrl+direction
vmap({ "<C-h>", tmux("move_left"), { desc = "Move to left pane" } })
vmap({ "<C-j>", tmux("move_bottom"), { desc = "Move to bottom pane" } })
vmap({ "<C-k>", tmux("move_top"), { desc = "Move to top pane" } })
vmap({ "<C-l>", tmux("move_right"), { desc = "Move to right pane" } })

--  Navigate neovim + neovim terminal emulator + tmux with ctrl+direction
tmap({ "<C-h>", tmux("move_left") })
tmap({ "<C-j>", tmux("move_bottom") })
tmap({ "<C-k>", tmux("move_top") })
tmap({ "<C-l>", tmux("move_right") })

-- easily escape terminal
tmap({ "<esc><esc>", "<C-\\><C-n><esc><cr>" })
tmap({ "<C-o>", "<C-\\><C-n><esc><cr>" })

-- resize windows with alt+hjkl in terminal mode (matches tmux behavior)
tmap({
  "<M-h>",
  function()
    require("config.tmux_resizer").resize_left()
    vim.cmd("startinsert")
  end,
  silent,
})
tmap({
  "<M-j>",
  function()
    require("config.tmux_resizer").resize_down()
    vim.cmd("startinsert")
  end,
  silent,
})
tmap({
  "<M-k>",
  function()
    require("config.tmux_resizer").resize_up()
    vim.cmd("startinsert")
  end,
  silent,
})
tmap({
  "<M-l>",
  function()
    require("config.tmux_resizer").resize_right()
    vim.cmd("startinsert")
  end,
  silent,
})

-- zoom a vim pane, <C-w> = to re-balance
nmap({ "<leader>-", ":wincmd _<cr>:wincmd \\|<cr>", { desc = "Zoom window" } })
nmap({ "<leader>=", ":wincmd =<cr>", { desc = "Rebalance window sizes" } })

-- close all other windows with <leader>o
nmap({ "<leader>wo", "<c-w>o", { desc = "Close other windows" } })

-- Switch between the last two files
nmap({ "<tab><tab>", "<c-^>", { desc = "Switch between alternate buffers" } })

-- copy to end of line
nmap({ "Y", "y$", { desc = "Yank to EOL" } })

-- copy to system clipboard
nmap({ "gy", '"+y', { desc = "Yank to clipboard" } })
vmap({ "gy", '"+y', { desc = "Yank to clipboard" } })

-- copy to to system clipboard (till end of line)
nmap({ "gY", '"+y$', { desc = "Yank to clipboard EOL" } })

-- copy entire file
nmap({ "<leader>ya", "ggyG", { desc = "[Y]ank [A]ll" } })

-- copy entire file to system clipboard
nmap({ "<leader>yA", 'gg"+yG', { desc = "[Y]ank [A]ll to clipboard" } })

-- Open files relative to current path:
nmap({ "<leader>ed", ':edit <C-R>=expand("%:p:h") . "/" <CR>', { desc = "[ED]it file" } })
nmap({ "<leader>sp", ':split <C-R>=expand("%:p:h") . "/" <CR>', { desc = "[SP]lit file" } })
nmap({ "<leader>vs", ':vsplit <C-R>=expand("%:p:h") . "/" <CR>', { desc = "[V]ertical [S]plit file" } })

-- move lines up and down in visual mode
vmap({ "J", ":move '>+1<CR>gv=gv", { desc = "Move selection down" } })
vmap({ "K", ":move '<-2<CR>gv=gv", { desc = "Move selection up" } })

-- source current file (useful when iterating on config)
nmap({
  "<leader>so",
  ':source %<CR>:lua vim.notify("File sourced!")<CR>',
  { desc = "[SO]urce file" },
})

-- Lazy.nvim (plugin manager)
nmap({ "<leader>ps", "<cmd>Lazy sync<CR>", { desc = "[P]lugin [S]ync" } })
nmap({ "<leader>pc", "<cmd>Lazy clean<CR>", { desc = "[P]lugin [C]lean" } })

local M = {}

-- stylua: ignore
M.lsp_mappings = function()
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  nmap { '<leader>D', vim.lsp.buf.type_definition, { buffer = true, desc = 'Type [D]ef' } }
  map { { 'n', 'v' }, '<leader>ca', vim.lsp.buf.code_action, { buffer = true, desc = '[C]ode [A]ction' } }
  nmap { 'K', vim.lsp.buf.hover, { buffer = true, desc = 'LSP Hover Doc' } }
  nmap { '<leader>rn', vim.lsp.buf.rename, { buffer = true, desc = '[R]e[n]ame Symbol Under Cursor' } }
  nmap { '<Leader>lh', function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled()) end, { desc = "toggle in[l]ay [h]ints" }}
end

M.fugitive_mappings = function()
  -- Git Stage file
  nmap({ "<leader>gS", ":Gwrite<CR>", { silent = true, desc = "[G]it [S]tage" } })
  nmap({ "<leader>gw", ":Gwrite<CR>", { silent = true, desc = "[G]it [W]rite" } })

  --  Revert file
  nmap({ "<Leader>gR", ":Gread<CR>", { silent = true, desc = "[G]it [R]ead (reverts file)" } })
end

---@type LazyKeysSpec[]
M.vim_test_mappings = {
  { "<leader>tn", ":TestNearest<CR>", silent = true, desc = "[T]est [N]earest" },
  { "<leader>tf", ":TestFile<CR>", silent = true, desc = "[T]est [F]ile" },
  { "<leader>ts", ":TestSuite<CR>", silent = true, desc = "[T]est [S]uite" },
  { "<leader>tl", ":TestLast<CR>", silent = true, desc = "[T]est [L]ast" },
}

M.flash_mappings = {
  {
    "<leader><leader>",
    mode = { "n", "x", "o" },
    function()
      require("flash").jump()
    end,
    desc = "Flash",
  },
  {
    "<leader><cr>",
    mode = { "n", "x", "o" },
    function()
      require("flash").treesitter()
    end,
    desc = "Flash Treesitter",
  },
  { "f" },
  { "F" },
  { "t" },
  { "T" },
  { ";" },
  { "," },
}

return M
