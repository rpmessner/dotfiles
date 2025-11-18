--  pretty diagnostics, references, telescope results, quickfix and location
--  list to help you solve all the trouble your code is causing.
---@type LazySpec
return {
  "folke/trouble.nvim",
  cmd = { "Trouble", "TroubleToggle" },
  dependencies = "nvim-tree/nvim-web-devicons",
  keys = {
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
    -- smart `[q` and `]q` mappings that work for both qf list and trouble
    {
      "[q",
      function()
        if require("trouble").is_open() then
          ---@diagnostic disable-next-line: missing-parameter
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
          ---@diagnostic disable-next-line: missing-parameter
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
  },
  opts = {},
}
