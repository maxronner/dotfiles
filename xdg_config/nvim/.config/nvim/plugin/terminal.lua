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

vim.keymap.set("n", "<leader>o", "<cmd>silent !tmux-scratch<CR>",
  { silent = true, desc = "Swap tmux pane between foreground and background" })

vim.keymap.set("n", "<leader>i", function()
  local filepath = vim.fn.expand("%:p")
  vim.opt_local.relativenumber = false
  vim.cmd.redraw()
  vim.ui.input({ prompt = "Ask AI about file: " }, function(input)
    -- Restore relativenumber after user input is complete
    vim.schedule(function()
      vim.opt_local.relativenumber = true
    end)
    if not input or input == "" then
      return
    end
    local cmd = string.format("<cmd>silent !tmux-scratch -m ai -- 'ai-chat \"%s\" < %s ; read'<CR>",
      input,
      filepath)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", false)
  end)
end, { desc = "Ask AI about file" })



vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.winbar = ""
  end,
})
