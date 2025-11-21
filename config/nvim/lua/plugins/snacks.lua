local picker = function(fun, opts)
  if opts == nil then
    opts = {}
  end

  return function()
    Snacks.picker[fun](opts)
  end
end

return {
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
      bigfile = { enabled = true },
      notifier = { enabled = true },
      quickfile = { enabled = true },
      statuscolumn = { enabled = true },
      ---@class snacks.indent.Config
      indent = {
        enabled = true,
        animate = { enabled = false },
        -- this is what makes the scope look like an arrow
        chunk = { enabled = true },
      },
      words = { enabled = true },
      ---@class snacks.zen.Config
      zen = { enabled = true },
      scope = { enabled = true },
      input = { enabled = true },
      explorer = { enabled = false },
      layout = { enabled = true },

      picker = {
        enabled = true,
        win = {
          input = {
            keys = {
              -- I use the readline <c-a> to jump to the beginning of the line
              ["<c-a>"] = false,

              -- the default is <c-s> but I'm used to <c-x> from telescope
              ["<c-x>"] = { "edit_split", mode = { "i", "n" } },
            },
          },
        },
      },
      dashboard = {
        enabled = true,
        preset = {
          keys = {
            {
              icon = " ",
              key = "f",
              desc = "Find File",
              action = ":lua Snacks.dashboard.pick('files', {hidden = true})",
            },
            { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
            {
              icon = " ",
              key = "g",
              desc = "Find Text",
              action = ":lua Snacks.dashboard.pick('live_grep', {hidden = true, need_search = false})",
            },
            { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
            {
              icon = " ",
              key = "c",
              desc = "Config",
              action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})",
            },
            { icon = "󰣪 ", key = "m", desc = "Mason", action = ":Mason" },
            { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy", enabled = package.loaded.lazy ~= nil },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
          header = [[
  ▄▄▄█████▓▓█████  ▒█████   ██▒   █▓ ██▓ ███▄    █
  ▓  ██▒ ▓▒▓█   ▀ ▒██▒  ██▒▓██░   █▒▓██▒ ██ ▀█   █
  ▒ ▓██░ ▒░▒███   ▒██░  ██▒ ▓██  █▒░▒██▒▓██  ▀█ ██▒
  ░ ▓██▓ ░ ▒▓█  ▄ ▒██   ██░  ▒██ █░░░██░▓██▒  ▐▌██▒
    ▒██▒ ░ ░▒████▒░ ████▓▒░   ▒▀█░  ░██░▒██░   ▓██░
    ▒ ░░   ░░ ▒░ ░░ ▒░▒░▒░    ░ ▐░  ░▓  ░ ▒░   ▒ ▒
  ░     ░ ░  ░  ░ ▒ ▒░    ░ ░░   ▒ ░░ ░░   ░ ▒░
    ░         ░   ░ ░ ░ ▒       ░░   ▒ ░   ░   ░ ░
    ░  ░    ░ ░        ░   ░           ░
                        ░
          ]],
        },
        sections = {
          { section = "header" },
          { section = "keys", gap = 1, padding = 1 },
          { section = "startup" },
        },
      },
    },
    keys = {
      { "<leader>,", picker("buffers"), desc = "Buffers" },
      { "<leader>/", picker("lines"), desc = "Fuzzy Buffer Lines" },
      { "<leader>:", picker("command_history"), desc = "Command History" },
      { "<leader>pp", picker("registers"), desc = "Registers" },
      { "<leader>fi", picker("icons"), desc = "[F]ind [I]cons" },
      { "<leader>fu", picker("undo"), desc = "[F]ind [U]ndo" },
      { "<leader>lg", picker("grep", { need_search = false }), desc = "[L]ive [G]rep" },
      { "<leader>fw", picker("grep_word"), mode = { "n", "v" }, desc = "[F]ind [W]ord" },
      { "<leader>fd", picker("files", { cwd = "~/.dotfiles" }), desc = "[F]ind [D]otfiles" },
      { "<leader>gF", picker("git_diff"), desc = "[F]ind [G]it [D]iff" },
      { "<leader>f:", picker("commands"), desc = "Command search" },
      { "<leader>f;", picker("command_history"), desc = "Command History" },
      { "<leader>f?", picker("search_history"), desc = "Search History" },
      { "<leader>ff", picker("files", { hidden = true }), desc = "[F]ind [F]iles" },
      { "<leader>fe", picker("files", { args = { "-e=ex", "-e=exs", "-e=heex" } }), desc = "[F]ind [E]lixir" },
      {
        "<leader>ft",
        picker("files", { args = { "-e=ts", "-e=tsx", "-e=js", "-e=jsx", "-e=json" } }),
        desc = "[F]ind [T]ypeScript",
      },
      { "<leader>fl", picker("files", { args = { "-e=lua" } }), desc = "[F]ind [L]ua" },
      { "<leader>fg", picker("grep", { hidden = true, need_search = false }), desc = "[F]ind w/ [G]rep" },
      { "<leader>fh", picker("help"), desc = "[F]ind [H]elp" },
      { "<leader>fk", picker("keymaps"), desc = "[F]ind [K]eymaps" },
      { "<leader>fp", picker("pr_files"), desc = "[F]ind [P]R files" },
      { "<leader>fs", picker("git_status"), desc = "[F]ind (Git) [S]tatus" },
      { "<leader>fc", picker("git_status", { pattern = "UU" }), desc = "[F]ind (Git) [C]onflict" },
      { "<leader>bb", picker("buffers"), desc = "Find Buffers" },
      { "<leader>fb", picker("explorer"), desc = "[F]ile [B]rowser" },
      {
        "<leader>fo",
        picker("recent", { filter = { cwd = true, paths = { [".git/COMMIT_EDITMSG"] = false } } }),
        desc = "[F]ile [O]ld files",
      },
      -- bc = buffer commits (like gitv!)
      { "<leader>bc", picker("git_log_file"), desc = "[B]uffer [C]ommits" },
      { "<leader>bh", picker("git_log_file"), desc = "[B]uffer [H]istory" },

      { "<leader>nt", picker("explorer", { follow_file = false }), { desc = "[N]erdTree (not really) [T]oggle" } },
      {
        "<leader>nf",
        picker("explorer", { follow_file = true }),
        { desc = "[N]erdTree (not really) [F]ile (toggle)" },
      },
      { "<leader>tt", picker("explorer"), { desc = "[T]ree [T]oggle" } },
      { "<leader>f<CR>", picker("resume"), desc = "Finder Resume" },

      { "<leader>ls", picker("lsp_config"), desc = "[L]SP [S]ettings" },

      -- muscle memory
      { "<C-p>", picker("files"), desc = "Find Files" },
      { "<C-b>", picker("buffers"), desc = "Find Buffers" },

      -- insert mode pickers
      { "<C-q>", picker("icons"), mode = "i", desc = "Insert Icon" },

      -- better spell suggestions
      { "z=", picker("spelling"), desc = "Spelling Suggestions" },

      -- LSP
      { "<leader>ds", picker("lsp_symbols"), desc = "[D]ocument [S]ymbols" },
      { "gd", picker("lsp_definitions"), desc = "[G]o to [d]efinition" },
      { "gD", picker("lsp_declarations"), desc = "[G]o to [D]ecleration" },
      { "gr", picker("lsp_references"), desc = "[G]o to [R]eferences" },
    },
  },
}
