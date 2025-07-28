return {
  {
    "hrsh7th/nvim-cmp",
    lazy = false,
    priority = 100,
    dependencies = {
      "onsails/lspkind.nvim",
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-cmdline",
      {
        "L3MON4D3/LuaSnip",
        build = "make install_jsregexp",
        dependencies = {
          "rafamadriz/friendly-snippets",
          "saadparwaiz1/cmp_luasnip",
        },
      },
      {
        "supermaven-inc/supermaven-nvim",
        config = function()
          require("supermaven-nvim").setup {
            keymaps = {
              accept_suggestion = "<C-a>",
              clear_suggestion = "<C-]>",
              accept_word = "<C-f>",
            },
            disable_inline_completion = false,
            condition = function()
              local notebook = vim.env.ZK_NOTEBOOK_DIR
              local bufname = vim.api.nvim_buf_get_name(0)
              if notebook and bufname:find(notebook, 1, true) then
                return true
              end
              return false
            end
          }
        end,
      },
    },
    config = function()
      require "custom.completion"
    end,
  },
}
