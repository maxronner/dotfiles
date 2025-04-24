-- Open terminal in bottom split (1/5 screen height)
--vim.keymap.set("n", "<leader>o", function()
--  local total_lines = vim.o.lines
--  local term_height = math.floor(total_lines / 5)
--
--  vim.cmd.new()
--  vim.cmd.term()
--  vim.cmd.wincmd("J")
--  vim.api.nvim_win_set_height(0, term_height)
--  vim.cmd.startinsert()
--end, { desc = "Open terminal in bottom split (1/5 screen height)" })

vim.keymap.set("n", "<leader>o", "<cmd>silent !tmux-spawner<CR>",
  { silent = true, desc = "Swap tmux pane between foreground and background" })

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.winbar = ""
  end,
})
