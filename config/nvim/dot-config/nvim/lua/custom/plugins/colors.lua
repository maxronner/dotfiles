function ColorMyPencils(color)
  color = color or "rose-pine-moon"
  vim.cmd.colorscheme(color)

  vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
  vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
end

return {

  {
    "erikbackman/brightburn.vim",
  },

  {
    "folke/tokyonight.nvim",
    lazy = false,
    opts = {},
    config = function()
      ColorMyPencils()
    end
  },
  {
    "ellisonleao/gruvbox.nvim",
    name = "gruvbox",
    config = function()
      require("gruvbox").setup({
        terminal_colors = true, -- add neovim terminal colors
        undercurl = true,
        underline = false,
        bold = true,
        italic = {
          strings = false,
          emphasis = false,
          comments = false,
          operators = false,
          folds = false,
        },
        strikethrough = true,
        invert_selection = false,
        invert_signs = false,
        invert_tabline = false,
        invert_intend_guides = false,
        inverse = true, -- invert background for search, diffs, statuslines and errors
        contrast = "",  -- can be "hard", "soft" or empty string
        palette_overrides = {},
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
    end,
  },
  {
    "folke/tokyonight.nvim",
    config = function()
      require("tokyonight").setup({
        -- your configuration comes here
        -- or leave it empty to use the default settings
        style = "storm",        -- The theme comes in three styles, `storm`, `moon`, a darker variant `night` and `day`
        transparent = true,     -- Enable this to disable setting the background color
        terminal_colors = true, -- Configure the colors used when opening a `:terminal` in Neovim
        styles = {
          -- Style to be applied to different syntax groups
          -- Value is any valid attr-list value for `:help nvim_set_hl`
          comments = { italic = false },
          keywords = { italic = false },
          -- Background styles. Can be "dark", "transparent" or "normal"
          sidebars = "dark", -- style for sidebars, see below
          floats = "dark",   -- style for floating windows
        },
      })
    end
  },

  {
    "rose-pine/neovim",
    name = "rose-pine",
    config = function()
      require('rose-pine').setup({
        disable_background = true,
        enable = {
          terminal = true,
        },
        styles = {
          italic = false,
        },
      })

      ColorMyPencils();
    end
  },
  {
    "catgoose/nvim-colorizer.lua",
    config = function()
      require("colorizer").setup({
        filetypes = { "*" },     -- Filetype options.  Accepts table like `user_default_options`
        buftypes = {},           -- Buftype options.  Accepts table like `user_default_options`
        -- Boolean | List of usercommands to enable.  See User commands section.
        user_commands = true,    -- Enable all or some usercommands
        lazy_load = false,       -- Lazily schedule buffer highlighting setup function
        user_default_options = {
          names = false,         -- "Name" codes like Blue or red.  Added from `vim.api.nvim_get_color_map()`
          names_opts = {         -- options for mutating/filtering names.
            lowercase = true,    -- name:lower(), highlight `blue` and `red`
            camelcase = true,    -- name, highlight `Blue` and `Red`
            uppercase = false,   -- name:upper(), highlight `BLUE` and `RED`
            strip_digits = true, -- ignore names with digits,
            -- highlight `blue` and `red`, but not `blue3` and `red4`
          },
          -- Expects a table of color name to #RRGGBB value pairs.  # is optional
          -- Example: { cool = "#107dac", ["notcool"] = "ee9240" }
          -- Set to false to disable, for example when setting filetype options
          names_custom = false,   -- Custom names to be highlighted: table|function|false
          RGB = true,             -- #RGB hex codes
          RGBA = true,            -- #RGBA hex codes
          RRGGBB = true,          -- #RRGGBB hex codes
          RRGGBBAA = false,       -- #RRGGBBAA hex codes
          AARRGGBB = false,       -- 0xAARRGGBB hex codes
          rgb_fn = false,         -- CSS rgb() and rgba() functions
          hsl_fn = false,         -- CSS hsl() and hsla() functions
          css = false,            -- Enable all CSS *features*:
          -- names, RGB, RGBA, RRGGBB, RRGGBBAA, AARRGGBB, rgb_fn, hsl_fn
          css_fn = false,         -- Enable all CSS *functions*: rgb_fn, hsl_fn
          -- Tailwind colors.  boolean|'normal'|'lsp'|'both'.  True sets to 'normal'
          tailwind = false,       -- Enable tailwind colors
          tailwind_opts = {       -- Options for highlighting tailwind names
            update_names = false, -- When using tailwind = 'both', update tailwind names from LSP results.  See tailwind section
          },
          -- parsers can contain values used in `user_default_options`
          sass = { enable = false, parsers = { "css" } }, -- Enable sass colors
          -- Highlighting mode.  'background'|'foreground'|'virtualtext'
          mode = "virtualtext",                           -- Set the display mode
          -- Virtualtext character to use
          virtualtext = "■",
          -- Display virtualtext inline with color.  boolean|'before'|'after'.  True sets to 'after'
          virtualtext_inline = true,
          -- Virtualtext highlight mode: 'background'|'foreground'
          virtualtext_mode = "foreground",
          -- update color values even if buffer is not focused
          -- example use: cmp_menu, cmp_docs
          always_update = false,
          -- hooks to invert control of colorizer
          hooks = {
            -- called before line parsing.  Accepts boolean or function that returns boolean
            -- see hooks section below
            disable_line_highlight = false,
          },
        },
      })
    end,
  }
}
