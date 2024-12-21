require("maxronner.set")
require("maxronner.remap")
require("maxronner.lazy_init")

local augroup = vim.api.nvim_create_augroup
local maxronnerGroup = augroup('maxronner', {})

local autocmd = vim.api.nvim_create_autocmd

autocmd({"BufWritePre"}, {
    group = maxronnerGroup,
    pattern = "*",
    command = [[%s/\s\+$//e]],
})
