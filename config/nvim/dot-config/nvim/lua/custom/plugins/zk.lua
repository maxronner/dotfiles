return {
  "zk-org/zk-nvim",
  config = function()
    require("zk").setup({
      -- Can be "telescope", "fzf", "fzf_lua", "minipick", "snacks_picker",
      -- or select" (`vim.ui.select`).
      picker = "select",

      lsp = {
        -- `config` is passed to `vim.lsp.start(config)`
        config = {
          name = "zk",
          cmd = { "zk", "lsp" },
          filetypes = { "markdown" },
          -- on_attach = ...
          -- etc, see `:h vim.lsp.start()`
        },

        -- automatically attach buffers in a zk notebook that match the given filetypes
        auto_attach = {
          enabled = true,
        },
      },
    })
    local opts = { noremap = true, silent = false }

    vim.api.nvim_set_keymap("n", "<leader>zn", "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>",
      vim.tbl_extend("force", opts or {}, { desc = "Zettelkasten: New Note" }))

    vim.api.nvim_set_keymap("n", "<leader>zo", "<Cmd>ZkNotes { sort = { 'modified' } }<CR>",
      vim.tbl_extend("force", opts or {}, { desc = "Zettelkasten: Open Note" }))

    vim.api.nvim_set_keymap("n", "<leader>zt", "<Cmd>ZkTags<CR>",
      vim.tbl_extend("force", opts or {}, { desc = "Zettelkasten: Show Tags" }))

    vim.api.nvim_set_keymap("n", "<leader>zf",
      "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>",
      vim.tbl_extend("force", opts or {}, { desc = "Zettelkasten: Search Notes" }))

    vim.api.nvim_set_keymap("v", "<leader>zf", ":'<,'>ZkMatch<CR>",
      vim.tbl_extend("force", opts or {}, { desc = "Zettelkasten: Search for Selection" }))
  end
}
