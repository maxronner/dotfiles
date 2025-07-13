local colorscheme = "rose-pine-moon"
vim.cmd.colorscheme(colorscheme)

vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })

vim.api.nvim_create_user_command("ReloadTheme", function()
  dofile(vim.fn.stdpath("config") .. "/plugin/colors.lua")
end, {})
