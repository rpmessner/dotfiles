-- vim-be-good - Game to practice Vim motions
-- Interactive training for improving Vim efficiency
local keymaps = require("config.keymaps")

return {
  "ThePrimeagen/vim-be-good",
  cmd = "VimBeGood", -- Only load when running :VimBeGood command
  keys = keymaps.vim_be_good_mappings,
}
