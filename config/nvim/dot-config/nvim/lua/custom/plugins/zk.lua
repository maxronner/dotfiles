return {
  "zk-org/zk-nvim",
  config = function()
    require("zk").setup({
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
    local global_leader_maps = {
      ["<leader>zd"] = { "<Cmd>ZkDaily<CR>", "Zettelkasten: Daily Note" },
      ["<leader>zD"] = { "<Cmd>ZkYesterday<CR>", "Zettelkasten: Yesterday" },
      ["<leader>zn"] = { "<Cmd>ZkNew { title = vim.fn.input('Title: ') }<CR>", "Zettelkasten: New Note" },
      ["<leader>zo"] = { "<Cmd>ZkNotes { sort = { 'modified' } }<CR>", "Zettelkasten: Open Note" },
      ["<leader>zt"] = { "<Cmd>ZkTags<CR>", "Zettelkasten: Show Tags" },
      ["<leader>zf"] = { "<Cmd>ZkNotes { sort = { 'modified' }, match = { vim.fn.input('Search: ') } }<CR>", "Zettelkasten: Search Notes" },
      -- Visual mode search for selection
      ["<leader>zf_v"] = { ":'<,'>ZkMatch<CR>", "Zettelkasten: Search for Selection", mode = "v" },
    }

    for key, map in pairs(global_leader_maps) do
      local mode = map.mode or "n"
      -- Remove _v suffix from key when setting visual mode mapping
      local keymap = key:gsub("_v$", "")
      vim.keymap.set(mode, keymap, map[1], vim.tbl_extend("force", opts, { desc = map[2] }))
    end

    vim.api.nvim_create_user_command("ZkDaily", function()
      require("zk.commands").get("ZkNew")({
        dir = "journal/daily",
        no_input = true,
      })
    end, {})

    vim.api.nvim_create_user_command("ZkWeekly", function()
      require("zk.commands").get("ZkNew")({
        dir = "journal/weekly",
        no_input = true,
      })
    end, {})

    vim.api.nvim_create_user_command("ZkYesterday", function()
      local date = os.date("%Y-%m-%d", os.time() - 86400)
      require("zk.commands").get("ZkNew")({
        date = date,
        dir = "journal/daily",
        no_input = true,
      })
    end, {})
  end
}
