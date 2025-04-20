vim.g.mapleader = " "

vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")

vim.keymap.set("x", "<leader>p", [["_dP]])

vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]])
vim.keymap.set("n", "<leader>Y", [["+Y]])

vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d")

vim.keymap.set("i", "<C-c>", "<Esc>")

vim.keymap.set("i", "<C-Del>", "<C-o>de")
vim.keymap.set("n", "<C-Del>", "de")

vim.keymap.set("n", "<leader>f", vim.lsp.buf.format)

vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz")
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz")
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz")
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz")

-- Open alternate file
vim.keymap.set({ "n", "v" }, "<leader>e", "<C-6>")

vim.keymap.set('n', '<leader>Q', vim.diagnostic.setqflist, { desc = 'Diagnostics to quickfix' })

vim.keymap.set("n", "<C-s>", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod -x %<CR>", { silent = true })

vim.keymap.set("n", "<leader>fd", "<cmd> w !git diff % -<CR>")

vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end)

-- Copy diagnostic message to clipboard
vim.keymap.set('n', '<leader>cd', function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
  local json = vim.json.encode(diagnostics)
  vim.fn.system("echo '" .. json .. "' | jq -r 'map(.message) | join(\", \")' | wl-copy")
end
, { noremap = true, silent = true })

-- Swap false and true
vim.keymap.set("n", "<leader>bb", function()
  local word = vim.fn.expand("<cword>")
  if word == "true" then
    vim.cmd("normal! ciwfalse")
  elseif word == "false" then
    vim.cmd("normal! ciwtrue")
  end
end, { silent = true })
