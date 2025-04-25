local autocmd = vim.api.nvim_create_autocmd

-- Remove trailing whitespace on save
autocmd({ "BufWritePre" }, {
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Format on save
autocmd({ "BufWritePre" }, {
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

