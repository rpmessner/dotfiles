-- vim-be-good - Game to practice Vim motions
-- Interactive training for improving Vim efficiency
return {
  "ThePrimeagen/vim-be-good",
  cmd = "VimBeGood", -- Only load when running :VimBeGood command
  keys = {
    { "<leader>vg", "<cmd>VimBeGood<cr>", desc = "[V]im Be [G]ood - Practice motions" },
  },
}
