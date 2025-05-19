local data = assert(vim.fn.stdpath "data") --[[@as string]]
local telescope = require "telescope"

telescope.setup({
  defaults = {
    file_ignore_patterns = {},
    history = {
      path = vim.fs.joinpath(data, "telescope_history.sqlite3"),
      limit = 100,
    },
  },
  extensions = {
    wrap_results = true,

    fzf = {},
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {},
    },
  },
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "smart_history")
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "frecency")

local builtin = require("telescope.builtin")
vim.keymap.set("n", "<space>/", builtin.current_buffer_fuzzy_find, { desc = "Telescope: Fuzzy find in current buffer" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope: Keymaps" })
vim.keymap.set("n", "<leader>fp", builtin.find_files, { desc = "Telescope: Find files" })
vim.keymap.set("n", "<leader>fg", builtin.git_files, { desc = "Telescope: Git files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: Buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: Help tags" })
vim.keymap.set("n", "<leader>ft", builtin.live_grep, { desc = "Telescope: Live grep" })
vim.keymap.set("n", "<leader>fs", builtin.grep_string, { desc = "Telescope: Grep selection" })
vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Telescope: Command history" })
vim.keymap.set("n", "<leader>fH", builtin.search_history, { desc = "Telescope: Search history" })
vim.keymap.set("n", "<leader>vv", function()
  builtin.find_files { cwd = vim.fn.stdpath "config", prompt_title = "Nvim Config" }
end, { desc = "Telescope: Find files in config" })

vim.keymap.set("n", "<leader>ff", function()
  telescope.extensions.frecency.frecency {
    workspace = "CWD",
    prompt_title = "Find Files (frecency)",
  }
end, { desc = "Telescope: Find frequent files" })
