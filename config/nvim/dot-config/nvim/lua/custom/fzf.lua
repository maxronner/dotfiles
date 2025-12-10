local fzf = require("fzf-lua")

local fd_excludes = {
  "--exclude", ".git",
  "--exclude", "node_modules",
  "--exclude", "dist",
  "--exclude", "build",
}

local rg_excludes = table.concat({
  "--glob=!**/.git/**",
  "--glob=!**/node_modules/**",
  "--glob=!**/dist/**",
  "--glob=!**/build/**",
}, " ")

fzf.setup({
  winopts = {
    height = 0.85,
    width = 0.85,
    border = "rounded",
  },

  files = {
    prompt = "Files > ",
    fd_opts = table.concat(
      vim.iter({ fzf.defaults.files.fd_opts, fd_excludes }):flatten()
    ),
  },

  keymaps = {
    ["<leader>ff"] = { fzf.lines },
  },

  grep = {
    rg_opts = "--column --line-number --smart-case --hidden " .. rg_excludes,
  },

  live_grep = {
    rg_opts = "--column --line-number --smart-case --hidden " .. rg_excludes,
  },
})

-- Buffers
vim.keymap.set("n", "<leader>/", fzf.lines, { desc = "FZF: Fuzzy find in current buffer" })
vim.keymap.set("n", "<leader>fb", fzf.buffers, { desc = "FZF: Buffers" })

-- Files
vim.keymap.set("n", "<leader>fp", fzf.files, { desc = "FZF: Find files" })
vim.keymap.set("n", "<leader>fP", function()
  fzf.files({ hidden = true, no_ignore = true })
end, { desc = "FZF: Find files (all)" })
vim.keymap.set("n", "<leader>fo", fzf.oldfiles, { desc = "FZF: Find old files" })
vim.keymap.set("n", "<leader>fi", fzf.git_files, { desc = "FZF: Git files" })

-- Grep
vim.keymap.set("n", "<leader>fg", fzf.live_grep, { desc = "FZF: Live grep" })
vim.keymap.set("x", "<leader>fw", fzf.grep_visual, { desc = "FZF: Grep selection" })
vim.keymap.set("n", "<leader>fw", fzf.grep_cword, { desc = "FZF: Grep word under cursor" })

-- Git
vim.keymap.set("n", "<leader>fc", fzf.git_branches, { desc = "FZF: Git branch checkout" })
vim.keymap.set("n", "<leader>fm", fzf.git_status, { desc = "FZF: Git status" })

-- History / help
vim.keymap.set("n", "<leader>:", fzf.command_history, { desc = "FZF: Command history" })
vim.keymap.set("n", "<leader>fH", fzf.search_history, { desc = "FZF: Search history" })
vim.keymap.set("n", "<leader>fh", fzf.helptags, { desc = "FZF: Help tags" })
vim.keymap.set("n", "<leader>fk", fzf.keymaps, { desc = "FZF: Keymaps" })

-- Neovim directories
vim.keymap.set("n", "<leader>vv", function()
  fzf.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "FZF: Find files in Neovim config" })

vim.keymap.set("n", "<leader>vl", function()
  fzf.files({ cwd = vim.fn.stdpath("data") .. "/lazy" })
end, { desc = "FZF: Find files in plugins" })

vim.keymap.set("n", "<leader>fd", fzf.lsp_definitions, { desc = "FZF: LSP Definitions" })
vim.keymap.set("n", "<leader>fr", fzf.lsp_references, { desc = "FZF: LSP References" })
vim.keymap.set("n", "<leader>ls", fzf.lsp_document_symbols, { desc = "FZF: LSP Document Symbols" })
