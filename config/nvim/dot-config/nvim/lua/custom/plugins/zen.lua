return {
  {
    "folke/zen-mode.nvim",
    dependencies = {
      "folke/twilight.nvim",
    },
    opts = {
      window = {
        width = 80,
        backdrop = 1,
        options = {
          number = false,
          relativenumber = false,
          signcolumn = "no",
          colorcolumn = ""
        },
      },
      plugins = {
        options = {
          enabled = true,
          ruler = false,
          showcmd = false,
          laststatus = 0,
        },
        twilight = { enabled = true }, -- optional: dims inactive code
        gitsigns = { enabled = false },
        tmux = { enabled = true },
      },
    },
    keys = {
      { "<leader>zm", "<cmd>ZenMode<CR>", desc = "Toggle Zen Mode" },
    }
  }
}
