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

vim.keymap.set("n", "<leader>O", function()
  local filepath = vim.fn.expand("%:p")
  vim.ui.input({ prompt = "Ask tgpt: " }, function(input)
    if not input or input == "" then
      return
    end
    -- Escape any single quotes in the input
    local escaped = input:gsub("'", [["'""]]) -- Shell-safe escaping
    local cmd = string.format("<cmd>silent !tmux-scratch ai \"bash -c 'tgpt \"%s\" < %s ; read'\"<CR>",
      "'" .. escaped .. "'",
      filepath)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", false)
  end)
end, { desc = "Ask gpt" })


vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.winbar = ""
  end,
})
