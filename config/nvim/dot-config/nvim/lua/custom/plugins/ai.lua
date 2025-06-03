return {
  {
    "github/copilot.vim",
    enabled = false,
  },
  {
    "TabbyML/vim-tabby",
    enabled = false,
    lazy = false,
    dependencies = {
      "neovim/nvim-lspconfig",
    },
    init = function()
      vim.g.tabby_agent_start_command = { "npx", "tabby-agent", "--stdio" }
      vim.g.tabby_inline_completion_trigger = "auto"
    end,
  },
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      require("codecompanion").setup({
        strategies = {
          chat = {
            adapter = "gemini",
          },
          inline = {
            adapter = "gemini",
          },
        },
      })
      vim.keymap.set({ "n", "v" }, "<leader>o", "<cmd>CodeCompanionActions<cr>",
        { noremap = true, silent = true, desc = "CodeCompanion: Actions" })
      vim.keymap.set({ "n", "v" }, "<leader>i", "<cmd>CodeCompanionChat Toggle<cr>",
        { noremap = true, silent = true, desc = "CodeCompanion: Chat Toggle" })
      vim.keymap.set("v", "ga", "<cmd>CodeCompanionChat Add<cr>",
        { noremap = true, silent = true, desc = "CodeCompanion: Chat Add" })
      vim.keymap.set("n", "<leader>gc", ":CodeCompanion /commit<CR>",
        { noremap = true, silent = true, desc = "CodeCompanion: Commit" })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
