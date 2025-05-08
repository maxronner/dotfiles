return {
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      local harpoon = require("harpoon")

      -- REQUIRED
      harpoon:setup()
      -- REQUIRED

      vim.keymap.set("n", "<C-a>", function() harpoon:list():add() end,
        { desc = "Harpoon: Add file to list" })

      vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end,
        { desc = "Harpoon: Toggle quick menu" })

      vim.keymap.set("n", "<leader>t", function() harpoon:list():select(1) end,
        { desc = "Harpoon: Jump to mark 1" })

      vim.keymap.set("n", "<leader>s", function() harpoon:list():select(2) end,
        { desc = "Harpoon: Jump to mark 2" })

      vim.keymap.set("n", "<leader>r", function() harpoon:list():select(3) end,
        { desc = "Harpoon: Jump to mark 3" })

      vim.keymap.set("n", "<leader>a", function() harpoon:list():select(4) end,
        { desc = "Harpoon: Jump to mark 4" })

      vim.keymap.set("n", "<leader>p", function() harpoon:list():prev() end,
        { desc = "Harpoon: Previous mark" })

      vim.keymap.set("n", "<leader>n", function() harpoon:list():next() end,
        { desc = "Harpoon: Next mark" })
    end
  }
}
