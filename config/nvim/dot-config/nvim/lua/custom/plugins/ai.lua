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
    enabled = true,
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
  {
    "yetone/avante.nvim",
    event = "VeryLazy",
    version = false, -- Never set this value to "*"! Never!
    opts = {
      -- add any opts here
      -- for example
      provider = "gemini",
      providers = {
        provider = "gemini",
        gemini = {
          model = "gemini-2.0-flash",
          timeout = 30000,
          extra_request_body = {
            generationConfig = {
              temperature = 0.75,
            },
          },
          use_ReAct_prompt = true,
        },
        openai = {
          endpoint = "https://api.openai.com/v1",
          model = "gpt-4o",               -- your desired model (or use gpt-4o, etc.)
          extra_request_body = {
            timeout = 30000,              -- Timeout in milliseconds, increase this for reasoning models
            temperature = 0.75,
            max_completion_tokens = 8192, -- Increase this to include reasoning tokens (for reasoning models)
            --reasoning_effort = "medium", -- low|medium|high, only used for reasoning models
          },
        },
      },
      mappings = {
        ask = "<leader>ia",
        new_ask = "<leader>in",
        edit = "<leader>ie",
        refresh = "<leader>ir",
        focus = "<leader>if",
        stop = "<leader>iS",
        toggle = {
          default = "<leader>it",
          debug = "<leader>id",
          hint = "<leader>ih",
          suggestion = "<leader>is",
          repomap = "<leader>iR",
        },
        files = {
          add_current = "<leader>ic",     -- Add current buffer to selected files
          add_all_buffers = "<leader>iB", -- Add all buffer files to selected files
        },
        select_model = "<leader>i?",      -- Select model command
        select_history = "<leader>ih",    -- Select history command
      },
    },
    -- if you want to build from source then do `make BUILD_FROM_SOURCE=true`
    build = "make",
    -- build = "powershell -ExecutionPolicy Bypass -File Build.ps1 -BuildFromSource false" -- for windows
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
      --- The below dependencies are optional,
      "echasnovski/mini.pick",         -- for file_selector provider mini.pick
      "nvim-telescope/telescope.nvim", -- for file_selector provider telescope
      "hrsh7th/nvim-cmp",              -- autocompletion for avante commands and mentions
      "ibhagwan/fzf-lua",              -- for file_selector provider fzf
      "echasnovski/mini.icons",        -- or nvim-tree/nvim-web-devicons
      {
        -- support for image pasting
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts = {
          -- recommended settings
          default = {
            embed_image_as_base64 = false,
            prompt_for_file_name = false,
            drag_and_drop = {
              insert_mode = true,
            },
            -- required for Windows users
            use_absolute_path = true,
          },
        },
      },
      {
        -- Make sure to set this up properly if you have lazy=true
        'MeanderingProgrammer/render-markdown.nvim',
        opts = {
          file_types = { "markdown", "Avante" },
        },
        ft = { "markdown", "Avante" },
      },
    },
  }
}
