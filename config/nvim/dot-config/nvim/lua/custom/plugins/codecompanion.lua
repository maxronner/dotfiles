return {
  {
    "olimorris/codecompanion.nvim",
    opts = {},
    enabled = true,
    event = "VeryLazy",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "echasnovski/mini.diff",
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
        adapters = {
          gemini = function()
            return require("codecompanion.adapters").extend("gemini", {
              env = {
                api_key = require("custom.passloader").get_var("GEMINI_API_KEY")
              }
            })
          end,
          openai = function()
            return require("codecompanion.adapters").extend("openai", {
              env = {
                api_key = require("custom.passloader").get_var("OPENAI_API_KEY")
              }
            })
          end
        }
      })
      vim.keymap.set({ "n", "v" }, "<leader>oo", "<cmd>CodeCompanionActions<cr>",
        { noremap = true, silent = true, desc = "CodeCompanion: Actions" })
      vim.keymap.set({ "n", "v" }, "<leader>ii", "<cmd>CodeCompanionChat Toggle<cr>",
        { noremap = true, silent = true, desc = "CodeCompanion: Chat Toggle" })
      vim.keymap.set("v", "ia", "<cmd>CodeCompanionChat Add<cr>",
        { noremap = true, silent = true, desc = "CodeCompanion: Chat Add" })
      vim.keymap.set("n", "<leader>ig", ":CodeCompanion /commit<CR>",
        { noremap = true, silent = true, desc = "CodeCompanion: Generate Git Commit" })

      -- Expand 'cc' into 'CodeCompanion' in the command line
      vim.cmd([[cab cc CodeCompanion]])
    end,
  },
}
