local M = {}

M.setup = function()
  ---@diagnostic disable-next-line: missing-fields
  require("nvim-treesitter.configs").setup({
    -- A list of parser names, or "all"
    ensure_installed = {
      "vimdoc", "javascript", "typescript", "c", "lua", "rust",
      "jsdoc", "bash", "go"
    },

    -- Install parsers synchronously (only applied to `ensure_installed`)
    sync_install = false,

    -- Automatically install missing parsers when entering buffer
    -- Recommendation: set to false if you don"t have `tree-sitter` CLI installed locally
    auto_install = true,

    indent = {
      enable = true
    },

    highlight = {
      -- `false` will disable the whole extension
      enable = true,
      disable = function(lang, buf)
        if lang == "html" then
          vim.notify(
            "HTML file, treesitter disabled for performance",
            vim.log.levels.WARN,
            { title = "Treesitter" }
          )
          return true
        end

        local max_filesize = 100 * 1024 -- 100 KB
        local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
        if ok and stats and stats.size > max_filesize then
          vim.notify(
            "File larger than 100KB, treesitter disabled for performance",
            vim.log.levels.WARN,
            { title = "Treesitter" }
          )
          return true
        end
      end,

      -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
      -- Set this to `true` if you depend on "syntax" being enabled (like for indentation).
      -- Using this option may slow down your editor, and you may see some duplicate highlights.
      -- Instead of true it can also be a list of languages
      additional_vim_regex_highlighting = { "markdown" },
    },

    textobjects = {
      lsp_interop = {
        enable = true,
        border = 'rounded',
        floating_preview_opts = {},
        peek_definition_code = {
          ["<leader>gf"] = "@function.outer",
          ["<leader>gF"] = "@class.outer",
        },
      },
      select = {
        enable = true,
        keymaps = {
          ["af"] = "@function.outer",
          ["if"] = "@function.inner",
          ["ac"] = "@class.outer",
        },
      },
      move = {
        enable              = true,
        set_to_root         = true,
        set_jumps           = true, -- whether to set jumps in the jumplist
        goto_next_start     = {
          ["]m"] = "@function.outer",
          ["]]"] = { query = "@class.outer", desc = "Next class start" },
          --
          -- You can use regex matching (i.e. lua pattern) and/or pass a list in a "query" key to group multiple queries.
          ["]o"] = "@loop.*",
          -- ["]o"] = { query = { "@loop.inner", "@loop.outer" } }
          --
          -- You can pass a query group to use query from `queries/<lang>/<query_group>.scm file in your runtime path.
          -- Below example nvim-treesitter's `locals.scm` and `folds.scm`. They also provide highlights.scm and indent.scm.
          ["]s"] = { query = "@local.scope", query_group = "locals", desc = "Next scope" },
          ["]z"] = { query = "@fold", query_group = "folds", desc = "Next fold" },
        },
        goto_next_end       = {
          ["]M"] = "@function.outer",
          ["]["] = "@class.outer",
        },
        goto_previous_start = {
          ["[m"] = "@function.outer",
          ["[["] = "@class.outer",
        },
        goto_previous_end   = {
          ["[M"] = "@function.outer",
          ["[]"] = "@class.outer",
        },
        -- Below will go to either the start or the end, whichever is closer.
        -- Use if you want more granular movements
        -- Make it even more gradual by adding multiple queries and regex.
        goto_next           = {
          ["]d"] = "@conditional.outer",
        },
        goto_previous       = {
          ["[d"] = "@conditional.outer",
        }
      },
      swap = {
        enable = true,
        swap_next = {
          ["<leader>ww"] = "@parameter.inner",
        },
        swap_previous = {
          ["<leader>ws"] = "@parameter.inner",
        },
      }
    },
  })
end

return M
