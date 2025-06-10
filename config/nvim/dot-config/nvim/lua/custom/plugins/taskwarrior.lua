return {
  {
    "fancypantalons/taskwarrior.nvim",
    upgrade = false,
    config = function()
      require("taskwarrior_nvim").setup()

      vim.keymap.set("n", "<leader>ft", function()
        require("taskwarrior_nvim").browser({ "ready" })
      end, { desc = "Telescope: Taskwarrior" })
    end,
  }
}
