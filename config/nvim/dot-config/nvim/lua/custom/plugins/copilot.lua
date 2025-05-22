return {
  {
    "github/copilot.vim",
    enabled = false,
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup()
      vim.keymap.set("n", "<leader>i", "<cmd>CodeCompanionActions<cr>",
        { noremap = true, silent = true, desc = "CodeCompanion: Actions" })
    end,
  },
}
