local ls = require("luasnip")
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node

return {
  s("shebang", {
    t({ "#!/usr/bin/env bash", "" }),
    i(1, "# description"),
    t({ "", "" }),
  }),
}
