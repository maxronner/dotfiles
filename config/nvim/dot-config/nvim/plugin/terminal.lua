local function open_terminal_bottom_split()
  local total_lines = vim.o.lines
  local term_height_ratio = 5 -- configurable ratio
  local term_height = math.floor(total_lines / term_height_ratio)

  vim.cmd.new()
  vim.cmd.term()
  vim.cmd.wincmd("J")
  vim.api.nvim_win_set_height(0, term_height)
  vim.cmd.startinsert()
end

vim.keymap.set("n", "<leader>o", function()
  -- Check if tmux-scratch is available
  if vim.fn.executable("tmux-scratch") == 1 then
    vim.cmd("silent !tmux-scratch")
  else
    -- Fallback to opening a terminal in a split
    open_terminal_bottom_split()
    vim.notify("tmux-scratch not found, opening regular terminal.", vim.log.levels.WARN)
  end
end, { desc = "Open/Swap tmux pane or open terminal" })

-- Ask AI about file
vim.keymap.set("n", "<leader>i", function()
  vim.opt_local.relativenumber = false
  vim.cmd.redraw()

  vim.ui.input({ prompt = "Ask AI about file: " }, function(input)
    vim.schedule(function()
      vim.opt_local.relativenumber = true
    end)

    if not input or input == "" then
      return
    end

    local filepath = vim.fn.expand("%:p")
    if vim.fn.filereadable(filepath) == 0 then
      vim.notify("File not accessible.", vim.log.levels.ERROR)
      return
    end

    local escaped_input = vim.fn.shellescape(input)
    local escaped_filepath = vim.fn.shellescape(filepath)

    local cmd = string.format("<cmd>silent !tmux-scratch -m ai -- 'ai-chat \"%s\" < %s'<CR>",
      escaped_input,
      escaped_filepath)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(cmd, true, false, true), "n", false)
  end)
end, { desc = "Ask AI about file" })

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.winbar = ""
  end,
})
