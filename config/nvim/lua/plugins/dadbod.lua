-- Database UI with vim-dadbod
---@type LazySpec
return {
  {
    "tpope/vim-dadbod",
    cmd = "DB",
  },
  {
    "kristijanhusak/vim-dadbod-ui",
    dependencies = { "tpope/vim-dadbod" },
    cmd = { "DBUI", "DBUIToggle", "DBUIAddConnection", "DBUIFindBuffer" },
    keys = {
      { "<leader>Du", "<cmd>DBUIToggle<cr>", desc = "[D]atabase [U]I" },
      { "<leader>Df", "<cmd>DBUIFindBuffer<cr>", desc = "[D]atabase [F]ind buffer" },
      { "<leader>Da", "<cmd>DBUIAddConnection<cr>", desc = "[D]atabase [A]dd connection" },
    },
    init = function()
      vim.g.db_ui_use_nerd_fonts = 1
      vim.g.db_ui_show_database_icon = 1

      -- Save queries to a project-local directory if it exists
      vim.g.db_ui_save_location = vim.fn.getcwd() .. "/.db_queries"

      -- Example connections (customize per project via .env or direnv)
      -- vim.g.dbs = {
      --   dev = "postgresql://localhost/myapp_dev",
      --   test = "postgresql://localhost/myapp_test",
      -- }
    end,
  },
  {
    "kristijanhusak/vim-dadbod-completion",
    dependencies = { "tpope/vim-dadbod", "kristijanhusak/vim-dadbod-ui" },
    ft = { "sql", "mysql", "plsql" },
    init = function()
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "sql", "mysql", "plsql" },
        callback = function()
          -- Add dadbod completion source to blink.cmp for SQL files
          -- Note: blink.cmp may need explicit source registration
          -- For now, this enables omnicompletion
          vim.bo.omnifunc = "vim_dadbod_completion#omni"
        end,
      })
    end,
  },
}
