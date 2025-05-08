return {
  "nvim-telescope/telescope.nvim",

  tag = "0.1.5",

  dependencies = {
    "nvim-lua/plenary.nvim"
  },

  config = function()
    require("telescope").setup({})

    local builtin = require("telescope.builtin")
    vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope: Keymaps" })
    vim.keymap.set("n", "<leader>fr", builtin.lsp_references, { desc = "Telescope: Find references" })
    vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope: Find files" })
    vim.keymap.set("n", "<leader>fp", builtin.git_files, { desc = "Telescope: Git files" })
    vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: Buffers" })
    vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: Help tags" })
    vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope: Live grep" })
    vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Telescope: Grep selection" })
    vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Telescope: Command history" })
    vim.keymap.set("n", "<leader>fH", builtin.search_history, { desc = "Telescope: Search history" })
    vim.keymap.set("n", "<leader>vv", function()
      builtin.find_files { cwd = vim.fn.stdpath "config", prompt_title = "Nvim Config" }
    end, { desc = "Telescope: Find files in config" })
  end
}
