local function get_comment_parts()
  local cs = vim.bo.commentstring
  local prefix = cs:match("^(.*)%%s") or ""
  local suffix = cs:match("%%s(.*)$") or ""
  return vim.trim(prefix), vim.trim(suffix)
end

local function is_commented(line, prefix, suffix)
  local has_prefix = vim.trim(line):find("^" .. vim.pesc(prefix))
  local has_suffix = suffix == "" or vim.trim(line):find(vim.pesc(suffix) .. "$")
  return has_prefix and has_suffix
end

local function toggle_lines(start_line, end_line)
  local lines = vim.api.nvim_buf_get_lines(0, start_line, end_line + 1, false)
  local prefix, suffix = get_comment_parts()

  local all_commented = true
  for _, line in ipairs(lines) do
    if not is_commented(line, prefix, suffix) then
      all_commented = false
      break
    end
  end

  for i, line in ipairs(lines) do
    if all_commented then
      line = line:gsub("^%s*" .. vim.pesc(prefix) .. "%s?", "", 1)
      if suffix ~= "" then
        line = line:gsub(vim.pesc(suffix) .. "%s*$", "", 1)
      end
    else
      line = prefix .. " " .. line
      if suffix ~= "" then
        line = line .. " " .. suffix
      end
    end
    lines[i] = line
  end

  vim.api.nvim_buf_set_lines(0, start_line, end_line + 1, false, lines)
end

local function toggle_comment()
  local mode = vim.fn.mode()
  if mode == "V" or mode == "v" then
    -- visual mode
    local lines = Get_visual_range()
    if lines then
      toggle_lines(lines.start_line - 1, lines.end_line - 1)
    end
  else
    -- normal mode
    local line = vim.api.nvim_win_get_cursor(0)[1] - 1
    toggle_lines(line, line)
  end
end

vim.keymap.set({ "n", "x" }, "<leader>cc", toggle_comment, { desc = "Toggle comment" })
