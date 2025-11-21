return {
  runtime = {
    version = "LuaJIT",
    path = {
      "lua/?.lua",
      "lua/?/init.lua",
    },
  },
  diagnostics = {
    globals = { "vim" },
  },
  workspace = {
    library = vim.env.VIMRUNTIME and {
      vim.env.VIMRUNTIME,
      "${3rd}/luv/library",
    } or {
      -- Fallback for CI/non-Neovim environments
      "$VIMRUNTIME",
      "${3rd}/luv/library",
    },
    checkThirdParty = false,
  },
}
