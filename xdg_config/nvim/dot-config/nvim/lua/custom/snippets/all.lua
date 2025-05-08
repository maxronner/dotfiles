local ls = require("luasnip")
local s = ls.snippet
local f = ls.function_node
local t = ls.text_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt
local rep = require("luasnip.extras").rep

ls.add_snippets("all", {
  s("curtime",
    f(function()
      return os.date('%Y-%m-%d %H:%M:%S')
    end)
  ),
})
