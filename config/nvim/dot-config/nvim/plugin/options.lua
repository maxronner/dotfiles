-- General
vim.opt.timeout = true
vim.opt.timeoutlen = 300
vim.opt.confirm = true
vim.opt.updatetime = 50
vim.opt.splitright = true
vim.opt.isfname:append("@-@")
vim.opt.virtualedit = "block"

-- UI
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "80"
vim.opt.relativenumber = true
vim.opt.nu = true

-- Indentation
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false

-- Files
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undofile = true

-- Search
vim.opt.hlsearch = true
vim.opt.incsearch = true
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Terminal
vim.opt.termguicolors = true

-- Tree-sitter based folding for all filetypes
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "nvim_treesitter#foldexpr()"
vim.opt.foldenable = true
vim.opt.foldlevel = 99
vim.opt.foldlevelstart = 99
