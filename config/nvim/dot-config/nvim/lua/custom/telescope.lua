local data = assert(vim.fn.stdpath "data") --[[@as string]]
local telescope = require "telescope"
local builtin = require "telescope.builtin"
local actions = require("telescope.actions")
local action_state = require("telescope.actions.state")

local function fzf_multi_select(prompt_bufnr)
  local picker = action_state.get_current_picker(prompt_bufnr)
  local num_selections = #picker:get_multi_selection()

  if num_selections > 1 then
    -- actions.file_edit throws - context of picker seems to change
    --actions.file_edit(prompt_bufnr)
    actions.send_selected_to_qflist(prompt_bufnr)
    actions.open_qflist(0)
  else
    actions.file_edit(prompt_bufnr)
  end
end

telescope.setup({
  defaults = {
    file_ignore_patterns = {},
    history = {
      path = vim.fs.joinpath(data, "telescope_history.sqlite3"),
      limit = 100,
    },
    mappings = {
      i = {
        ["<C-q>"] = require('telescope.actions').delete_buffer,
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
        ["<cr>"] = fzf_multi_select
      },
      n = {
        ["<C-q>"] = require('telescope.actions').delete_buffer,
        ["<tab>"] = actions.toggle_selection + actions.move_selection_next,
        ["<s-tab>"] = actions.toggle_selection + actions.move_selection_previous,
        ["<cr>"] = fzf_multi_select
      },
    }
  },
  extensions = {
    wrap_results = true,

    fzf = {
      fuzzy = true,                   -- false will only do exact matching
      override_generic_sorter = true, -- override the generic sorter
      override_file_sorter = true,    -- override the file sorter
      case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
    },
    ["ui-select"] = {
      require("telescope.themes").get_dropdown {},
    },
    frecency = {
      auto_validate = false,
      matcher = "fuzzy",
      path_display = { "filename_first" },
      ignore_patterns = { "*/.git", "*/.git/*", "*/.DS_Store" },
      bootstrap = true,
      default_workspace = "CWD",
      hide_current_buffer = true,
      prompt_title = "Find Files (frecency)",
    }
  },
})

pcall(telescope.load_extension, "fzf")
pcall(telescope.load_extension, "smart_history")
pcall(telescope.load_extension, "ui-select")
pcall(telescope.load_extension, "frecency")

local frecency = telescope.extensions.frecency
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Telescope: Fuzzy find in current buffer" })
vim.keymap.set("n", "<leader>fp", builtin.find_files, { desc = "Telescope: Find files" })
vim.keymap.set("n", "<leader>fi", builtin.git_files, { desc = "Telescope: Git files" })
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Telescope: Old files" })
vim.keymap.set("n", "<leader>fr", frecency.frecency, { desc = "Telescope: Find frequent files" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope: Buffers" })
vim.keymap.set("n", "<leader>ft", builtin.live_grep, { desc = "Telescope: Live grep" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Telescope: Grep selection" })
vim.keymap.set("n", "<leader>fm", builtin.git_status, { desc = "Telescope: Git status" })

vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope: Keymaps" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope: Help tags" })
vim.keymap.set("n", "<leader>fc", builtin.command_history, { desc = "Telescope: Command history" })
vim.keymap.set("n", "<leader>fH", builtin.search_history, { desc = "Telescope: Search history" })

vim.keymap.set("n", "<leader>vv", function()
  builtin.find_files { cwd = vim.fn.stdpath "config", prompt_title = "Nvim Config" }
end, { desc = "Telescope: Find files in config" })
