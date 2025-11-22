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
    ---@diagnostic disable-next-line: undefined-global
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

-- easily escape terminal
tmap({ "<esc><esc>", "<C-\\><C-n><esc><cr>" })
tmap({ "<C-o>", "<C-\\><C-n><esc><cr>" })

-- prevent ctrl+z from suspending processes in terminal mode
tmap({ "<C-z>", "<nop>", { desc = "Disabled (use exit or <C-d> instead)" } })

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

M.oil_mappings = {
  { "-", "<CMD>Oil<CR>", desc = "Open parent directory" },
  { "<leader>o", "<CMD>Oil<CR>", desc = "[O]il - Open parent directory" },
  { "<leader>O", "<CMD>Oil --float<CR>", desc = "[O]il - Open parent directory (float)" },
}

M.claude_code_mappings = {
  { "<leader>a", nil, desc = "AI/Claude Code" },
  { "<C-,", "<cmd>ClaudeCodeFocus<cr>", desc = "Toggle Claude", mode = { "n", "t" } },
  { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude" },
  { "<leader>af", "<cmd>ClaudeCodeFocus<cr>", desc = "Focus Claude" },
  { "<leader>ar", "<cmd>ClaudeCode --resume<cr>", desc = "Resume Claude" },
  { "<leader>aC", "<cmd>ClaudeCode --continue<cr>", desc = "Continue Claude" },
  { "<leader>am", "<cmd>ClaudeCodeSelectModel<cr>", desc = "Select Claude model" },
  { "<leader>ab", "<cmd>ClaudeCodeAdd %<cr>", desc = "Add current buffer" },
  { "<leader>as", "<cmd>ClaudeCodeSend<cr>", mode = "v", desc = "Send to Claude" },
  {
    "<leader>as",
    "<cmd>ClaudeCodeTreeAdd<cr>",
    desc = "Add file",
    ft = { "NvimTree", "neo-tree", "oil", "minifiles", "netrw" },
  },
  { "<leader>aa", "<cmd>ClaudeCodeDiffAccept<cr>", desc = "Accept diff" },
  { "<leader>ad", "<cmd>ClaudeCodeDiffDeny<cr>", desc = "Deny diff" },
  -- Claude History
  {
    "<leader>ah",
    function()
      require("claude-history.picker").open()
    end,
    desc = "Claude [H]istory (current session)",
  },
  {
    "<leader>aH",
    function()
      require("claude-history.picker").open({ all = true })
    end,
    desc = "Claude [H]istory (all sessions)",
  },
}

M.avante_mappings = {
  { "<leader>av", "<cmd>AvanteToggle<cr>", desc = "[AI] Toggle Avante" },
  { "<leader>ax", "<cmd>AvanteAsk<cr>", desc = "[AI] Ask Avante", mode = { "n", "v" } },
  { "<leader>ae", "<cmd>AvanteEdit<cr>", desc = "[AI] Edit with Avante", mode = "v" },
  { "<leader>aR", "<cmd>AvanteRefresh<cr>", desc = "[AI] Refresh Avante" },
  { "<leader>aF", "<cmd>AvanteFocus<cr>", desc = "[AI] Focus Avante" },
  { "<leader>aX", "<cmd>AvanteClear<cr>", desc = "[AI] Clear Avante" },
}

M.diffview_mappings = {
  { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "[G]it [D]iff view" },
  { "<leader>gh", "<cmd>DiffviewFileHistory %<cr>", desc = "[G]it [H]istory (current file)" },
  { "<leader>gH", "<cmd>DiffviewFileHistory<cr>", desc = "[G]it [H]istory (all)" },
  { "<leader>gc", "<cmd>DiffviewClose<cr>", desc = "[G]it diff [C]lose" },
}

M.trouble_mappings = {
  { "<leader>xw", "<cmd>Trouble diagnostics toggle<cr>", desc = "Workspace Diagnostics" },
  { "<leader>xd", "<cmd>Trouble diagnostics toggle filter.buf=0<cr>", desc = "Document Diagnostics" },
  { "<leader>xl", "<cmd>Trouble loclist toggle<cr>", desc = "Open Loclist" },
  { "<leader>xq", "<cmd>Trouble qflist toggle<cr>", desc = "Open Quickfix" },
  {
    "<leader>ss",
    "<cmd>Trouble symbols toggle focus=true<cr>",
    desc = "Symbols (Trouble)",
  },
  {
    "<leader>sx",
    "<cmd>Trouble lsp toggle focus=true win.position=right<cr>",
    desc = "LSP Definitions / references / ... (Trouble)",
  },
  {
    "[q",
    function()
      if require("trouble").is_open() then
        ---@diagnostic disable-next-line: missing-parameter, missing-fields
        require("trouble").prev({ skip_groups = true, jump = true })
      else
        local ok, err = pcall(vim.cmd.cprev)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end,
    desc = "Previous trouble/quickfix item",
  },
  {
    "]q",
    function()
      if require("trouble").is_open() then
        ---@diagnostic disable-next-line: missing-parameter, missing-fields
        require("trouble").next({ skip_groups = true, jump = true })
      else
        local ok, err = pcall(vim.cmd.cnext)
        if not ok then
          vim.notify(err, vim.log.levels.ERROR)
        end
      end
    end,
    desc = "Next trouble/quickfix item",
  },
  { "gR", "<cmd>Trouble lsp_references<cr>", desc = "[G]o to [R]eferences (Trouble)" },
}

M.conform_mappings = {
  {
    "<leader>cf",
    function()
      require("conform").format({ async = true, lsp_fallback = true })
    end,
    mode = { "n", "v" },
    desc = "[C]ode [F]ormat",
  },
}

M.ripgrep_mappings = {
  { "<leader>rg", 'y :Rg "<CR>', mode = "v", desc = "[R]ip[G]rep selection" },
  { "<Leader>rg", ":Rg <C-r><C-w><CR>", desc = "[R]ip[G]rep word under cursor" },
}

M.portal_mappings = {
  { "[j", "<cmd>Portal jumplist backward<cr>", desc = "portal backward" },
  { "]j", "<cmd>Portal jumplist forward<cr>", desc = "portal forward" },
}

M.hardtime_mappings = {
  {
    "<leader>th",
    function()
      require("hardtime").toggle()
    end,
    desc = "[T]oggle [H]ardtime",
  },
}

M.vim_be_good_mappings = {
  { "<leader>vg", "<cmd>VimBeGood<cr>", desc = "[V]im Be [G]ood - Practice motions" },
}

return M
