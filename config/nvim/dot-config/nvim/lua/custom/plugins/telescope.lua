return {
  "nvim-telescope/telescope.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",

    -- Lists files based on 'frecency' algorithm.
    "nvim-telescope/telescope-frecency.nvim",

    -- Sets prompt history to be project specific.
    "nvim-telescope/telescope-smart-history.nvim",
    "kkharji/sqlite.lua",

    -- Sets vim.ui.select to telescope.
    "nvim-telescope/telescope-ui-select.nvim",
  },

  config = function()
    require "custom.telescope"
  end
}
