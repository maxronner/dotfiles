---- Navigation ----

-- Cursor stays in place when joining lines / scrolling
vim.keymap.set("n", "J", "mzJ`z", { desc = "Join line below with cursor stay" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down, center screen" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up, center screen" })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next match, center screen" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Prev match, center screen" })

-- Terminal mode
vim.keymap.set("t", "<Esc>", "<C-\\><C-n>", { desc = "Escape terminal mode" })

-- Quickfix / location list navigation
vim.keymap.set("n", "<C-j>", "<cmd>cnext<CR>zz", { desc = "Next quickfix" })
vim.keymap.set("n", "<C-k>", "<cmd>cprev<CR>zz", { desc = "Prev quickfix" })
vim.keymap.set("n", "<leader>j", "<cmd>lnext<CR>zz", { desc = "Next loclist" })
vim.keymap.set("n", "<leader>k", "<cmd>lprev<CR>zz", { desc = "Prev loclist" })

-- Alternate file (toggle between buffers)
vim.keymap.set("n", "<leader>e", "<C-6>", { desc = "Alternate buffer" })

-- Search within visual selection
vim.keymap.set('x', '/', '<C-\\><C-n>`</\\%V', { desc = 'Search forward within visual selection' })
vim.keymap.set('x', '?', '<C-\\><C-n>`>?\\%V', { desc = 'Search backward within visual selection' })


---- Editing ----

-- Split line at midpoint
vim.keymap.set('n', '<leader>|', "gMea<CR><Esc>", { desc = "Split line at midpoint" })

-- Delete word forward
vim.keymap.set("i", "<C-Del>", "<C-o>de", { desc = "Delete word (insert mode)" })
vim.keymap.set("n", "<C-Del>", "de", { desc = "Delete word (normal mode)" })
vim.keymap.set("i", "<C-h>", "<C-o>dB", { desc = "Delete backwards (insert mode)" })

-- LSP formatting
vim.keymap.set("n", "<leader>bf", vim.lsp.buf.format, { desc = "Format buffer" })

-- Diagnostics to quickfix
vim.keymap.set('n', '<leader>Q', vim.diagnostic.setqflist, { desc = "Diagnostics to quickfix" })


---- Search ----

-- Search & replace word under cursor
vim.keymap.set("n", "<C-s>", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute word under cursor" })

-- Search & replace text under cursor
vim.keymap.set("n", "<C-t>", [[:%s/<C-r><C-w>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Substitute text under cursor" })

-- Clear search highlight
vim.keymap.set('n', '<Esc>', '<cmd>nohlsearch<CR>', { desc = 'Clear search highlight' })


---- Files ----

-- Make file executable/non-executable
vim.keymap.set("n", "<leader>x", "<cmd>!chmod +x %<CR>", { silent = true, desc = "Make file executable" })
vim.keymap.set("n", "<leader>X", "<cmd>!chmod -x %<CR>", { silent = true, desc = "Remove exec permission" })

-- Source current file
vim.keymap.set("n", "<leader><leader>", "<cmd>so<CR>", { desc = "Source current file" })


---- Clipboard ----

-- System clipboard
vim.keymap.set({ "n", "x" }, "<leader>y", [["+y]], { desc = "Yank to system clipboard" })
vim.keymap.set("n", "<leader>Y", [["+Y]], { desc = "Yank line to system clipboard" })

-- Delete without yanking
vim.keymap.set({ "n", "x" }, "<leader>d", "\"_d", { desc = "Delete (no yank)" })


---- Logic ----

vim.keymap.set("n", "<leader>cf", "<cmd>!find . | wc -l<CR>", { desc = "Count files in directory" })
vim.keymap.set("n", "<leader>cd",
  "<cmd>!find . -type f -not -path '*/.git/*' -exec wc -l {} \\; | awk '{ total += $1 } END { print \"Lines in workspace: \" total }'<CR>",
  { desc = "Count lines in all files of current directory" })
