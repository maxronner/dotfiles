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

vim.api.nvim_create_autocmd("TermOpen", {
  callback = function()
    vim.opt_local.winbar = ""
  end,
})

--- Get the visual selection range: start_line, start_col, end_line, end_col, mode
function Get_visual_range()
  local mode = vim.fn.mode()
  if mode ~= 'v' and mode ~= 'V' and mode ~= '\22' then
    return nil
  end

  local _, start_line, start_col = unpack(vim.fn.getpos("v"))
  local _, end_line, end_col = unpack(vim.fn.getpos("."))

  -- Normalize order
  if start_line > end_line or (start_line == end_line and start_col > end_col) then
    start_line, end_line = end_line, start_line
    start_col, end_col = end_col, start_col
  end

  return {
    start_line = start_line,
    start_col = start_col,
    end_line = end_line,
    end_col = end_col,
    mode = mode,
  }
end

--- Get the text from visual selection
local function get_visual_selection_text()
  local range = Get_visual_range()
  if not range then return nil end

  local lines = vim.api.nvim_buf_get_lines(0, range.start_line - 1, range.end_line, false)
  if #lines == 0 then return "" end

  if range.mode == '\22' then -- blockwise visual
    local out = {}
    for _, line in ipairs(lines) do
      if #line < range.end_col then
        line = line .. string.rep(" ", range.end_col - #line)
      end
      table.insert(out, line:sub(range.start_col, range.end_col))
    end
    return table.concat(out, "\n")
  else
    if range.mode == 'V' then
      range.start_col = 1
      range.end_col = -1
    end

    lines[1] = string.sub(lines[1], range.start_col)
    if #lines == 1 then
      lines[1] = string.sub(lines[1], 1, range.end_col - range.start_col + 1)
    else
      lines[#lines] = string.sub(lines[#lines], 1, range.end_col)
    end
    return table.concat(lines, "\n")
  end
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
    vim.fn.system({
      "tmux-scratch",
      "-m",
      "ai",
      "--",
      "ai-chat",
      escaped_input,
      "<",
      escaped_filepath,
    })
  end)
end, { desc = "Ask AI about file" })

-- Ask AI about visual selection
vim.keymap.set("v", "<leader>i", function()
  vim.ui.input({ prompt = "Ask AI about selection: " }, function(input)
    if not input or input == "" then
      return
    end

    local selection = get_visual_selection_text()
    if not selection or selection == "" then
      return
    end

    local placeholder = (vim.bo.filetype ~= "" and vim.bo.filetype) or "code"
    local output = string.format("```%s\n%s\n```%s\n%s", placeholder, selection, placeholder, input)
    local escaped_output = vim.fn.shellescape(output)

    --vim.notify(escaped_output, vim.log.levels.INFO)
    vim.fn.system({
      "tmux-scratch",
      "-m",
      "ai",
      "--",
      "ai-chat",
      escaped_output,
    })
  end)
end, { desc = "Ask AI about selection" })
