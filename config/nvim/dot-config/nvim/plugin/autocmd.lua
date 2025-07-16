vim.api.nvim_create_autocmd('TextYankPost', {
  desc = 'Highlight when yanking text',
  group = vim.api.nvim_create_augroup('kickstart-highlight-yank', { clear = true }),
  callback = function()
    vim.hl.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Remove trailing whitespace",
  pattern = "*",
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
    local changed = false

    for i, line in ipairs(lines) do
      local cleaned = line:gsub("%s+$", "")
      if cleaned ~= line then
        lines[i] = cleaned
        changed = true
      end
    end

    if changed then
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
    end
  end,
})

local blacklist_filetypes = {
  [""] = true, -- Unknown filetypes
  bin = true,
  image = true,
  pdf = true,
  zip = true,
  tar = true,
  csv = true,
  markdown_inline = true, -- Some LSP-special filetypes
}

vim.api.nvim_create_autocmd("BufWritePre", {
  desc = "Ensure trailing newline",
  pattern = "*",
  callback = function()
    if vim.bo.binary or blacklist_filetypes[vim.bo.filetype] then return end
    local buf = vim.api.nvim_get_current_buf()
    local line_count = vim.api.nvim_buf_line_count(buf)
    local last_line = vim.api.nvim_buf_get_lines(buf, line_count - 1, line_count, false)[1]
    if last_line ~= "" then
      vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, { "" })
    end
  end,
})

