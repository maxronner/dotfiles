require("maxronner.set")
require("maxronner.remap")
require("maxronner.lazy_init")
require("maxronner.snippets")

local augroup = vim.api.nvim_create_augroup
local maxronnerGroup = augroup('maxronner', {})

local autocmd = vim.api.nvim_create_autocmd

-- Remove trailing whitespace on save
autocmd({ "BufWritePre" }, {
  group = maxronnerGroup,
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- Format on save
autocmd({ "BufWritePre" }, {
  group = maxronnerGroup,
  pattern = "*",
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Organize imports (go) on save
autocmd({ "BufWritePre" }, {
  group = maxronnerGroup,
  pattern = "*.go",
  callback = function()
    local params = vim.lsp.util.make_range_params()
    params.context = { only = { "source.organizeImports" } }
    -- buf_request_sync defaults to a 1000ms timeout. Depending on your
    -- machine and codebase, you may want longer. Add an additional
    -- argument after params if you find that you have to write the file
    -- twice for changes to be saved.
    -- E.g., vim.lsp.buf_request_sync(0, "textDocument/codeAction", params, 3000)
    local result = vim.lsp.buf_request_sync(0, "textDocument/codeAction", params)
    for cid, res in pairs(result or {}) do
      for _, r in pairs(res.result or {}) do
        if r.edit then
          local enc = (vim.lsp.get_client_by_id(cid) or {}).offset_encoding or "utf-16"
          vim.lsp.util.apply_workspace_edit(r.edit, enc)
        end
      end
    end
    vim.lsp.buf.format({ async = false })
  end
})

autocmd('LspAttach', {
  group = maxronnerGroup,
  callback = function(e)
    local opts = { buffer = e.buf }

    vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end,
      vim.tbl_extend("force", opts, { desc = "Go to definition" }))

    vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end,
      vim.tbl_extend("force", opts, { desc = "Hover documentation" }))

    vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end,
      vim.tbl_extend("force", opts, { desc = "Workspace symbols" }))

    vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end,
      vim.tbl_extend("force", opts, { desc = "Open diagnostics float" }))

    vim.keymap.set("n", "<leader>vca", function() vim.lsp.buf.code_action() end,
      vim.tbl_extend("force", opts, { desc = "Code actions" }))

    vim.keymap.set("n", "<leader>vrr", function() vim.lsp.buf.references() end,
      vim.tbl_extend("force", opts, { desc = "References" }))

    vim.keymap.set("n", "<leader>vrn", function() vim.lsp.buf.rename() end,
      vim.tbl_extend("force", opts, { desc = "Rename symbol" }))

    vim.keymap.set("n", "<C-h>", function() vim.lsp.buf.signature_help() end,
      vim.tbl_extend("force", opts, { desc = "Signature help" }))

    vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end,
      vim.tbl_extend("force", opts, { desc = "Next diagnostic" }))

    vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end,
      vim.tbl_extend("force", opts, { desc = "Previous diagnostic" }))
  end,
})
