-- Move visual selection up/down
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { desc = "Move selection down" })
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { desc = "Move selection up" })

-- Increment/decrement numbers
vim.keymap.set({ "n", "v" }, "<C-c>", "<C-a>gv=gv", { desc = "Increment number" })
vim.keymap.set({ "n", "v" }, "<C-x>", "<C-x>gv=gv", { desc = "Decrement number" })

-- Cursor stays in place when joining lines / scrolling
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line below with cursor stay" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down, center screen" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up, center screen" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match, center screen" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev match, center screen" })

-- Paste over without yanking
vim.keymap.set("x", "<leader>p", [["_dP]], { desc = "Paste over (no yank)" })

-- System clipboard
vim.keymap.set({ "n", "v" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", "\"_d", { desc = "Delete (no yank)" })

-- Escape insert mode
vim.keymap.set("i", "<C-c>", "<Esc>", { desc = "Escape insert mode" })

-- Delete word forward
vim.keymap.set("i", "<C-Del>", "<C-o>de", { desc = "Delete word (insert mode)" })
vim.keymap.set("n", "<C-Del>", "de", { desc = "Delete word (normal mode)" })

-- LSP formatting
vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format, { desc = "Format buffer" })

-- Quickfix / location list navigation
vim.keymap.set("n", "<C-k>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
vim.keymap.set("n", "<C-j>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })
vim.keymap.set("n", "<leader>k", "<cmd>lnext<CR>zz", { desc = "Next loclist" })
vim.keymap.set("n", "<leader>j", "<cmd>lprev<CR>zz", { desc = "Prev loclist" })

-- Alternate file (toggle between buffers)
vim.keymap.set({ "n", "v" }, "<leader>e", "<C-6>", { desc = "Alternate buffer" })

-- Diagnostics to quickfix
vim.keymap.set('n', '<leader>Q', vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })

vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

-- Search & replace word under cursor
vim.keymap.set("n", "<C-s>", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor" })

-- Make file executable/non-executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod -x %<CR>", { silent = true, desc = "Remove exec permission" })

-- Source current file
vim.keymap.set("n", "<leader><leader>", function()
  vim.cmd("so")
end, { desc = "Source current file" })

-- Copy diagnostic message to clipboard
vim.keymap.set('n', '<leader>cd', function()
  local diagnostics = vim.diagnostic.get(0, { lnum = vim.fn.line('.') - 1 })
  local json = vim.json.encode(diagnostics)
  vim.fn.system("echo '" .. json .. "' | jq -r 'map(.message) | join(\", \")' | wl-copy")
end, { noremap = true, silent = true, desc = "Copy diagnostics to clipboard" })

-- Swap true/false
vim.keymap.set("n", "<leader>bb", function()
  local word = vim.fn.expand("<cword>")
  if word == "true" then
    vim.cmd("normal! ciwfalse")
  elseif word == "false" then
    vim.cmd("normal! ciwtrue")
  end
end, { silent = true, desc = "Toggle true/false" })

vim.keymap.set("n", "<leader>dl", "<cmd>!find . | wc -l<CR>", { desc = "Count lines in directory" })
