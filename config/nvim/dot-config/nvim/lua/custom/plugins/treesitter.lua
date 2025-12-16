return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    {
      "nvim-treesitter/nvim-treesitter-textobjects",
      branch = "main",
    }
  },
  config = function()
    require("custom.treesitter").setup()
  end,
}
