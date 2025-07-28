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
          local function is_zk_lsp_attached()
            local clients = vim.lsp.get_clients({ bufnr = 0 })
            for _, client in ipairs(clients) do
              if client.name == "zk" then
                return true
              end
            end
            return false
          end
          require("supermaven-nvim").setup {
            keymaps = {
              accept_suggestion = "<C-a>",
              clear_suggestion = "<C-]>",
              accept_word = "<C-f>",
            },
            disable_inline_completion = false,
            condition = function()
              -- disable supermaven if zk LSP is attached
              if is_zk_lsp_attached() then
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
