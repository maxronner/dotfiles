local headers = {
  {
    [[                                                                       ]],
    [[                                                                     ]],
    [[       ███████████           █████      ██                     ]],
    [[      ███████████             █████                             ]],
    [[      ████████████████ ███████████ ███   ███████     ]],
    [[     ████████████████ ████████████ █████ ██████████████   ]],
    [[    █████████████████████████████ █████ █████ ████ █████   ]],
    [[  ██████████████████████████████████ █████ █████ ████ █████  ]],
    [[ ██████  ███ █████████████████ ████ █████ █████ ████ ██████ ]],
    [[ ██████   ██  ███████████████   ██ █████████████████ ]],
    [[ ██████   ██  ███████████████   ██ █████████████████ ]],
  },
  {
    [[                                                            ]],
    [[ mmm   mm                                   ##              ]],
    [[ ###   ##                                   ""              ]],
    [[ ##"#  ##   m####m    m####m   ##m  m##   ####     ####m##m ]],
    [[ ## ## ##  ##mmmm##  ##"  "##   ##  ##      ##     ## ## ## ]],
    [[ ##  #m##  ##""""""  ##    ##   "#mm#"      ##     ## ## ## ]],
    [[ ##   ###  "##mmmm#  "##mm##"    ####    mmm##mmm  ## ## ## ]],
    [[ ""   """    """""     """"       ""     """"""""  "" "" "" ]],
  },

  {
    [[             ]],
    [[  ／|_       ]],
    [[ (o o /      ]],
    [[  |.   ~.    ]],
    [[  じしf_,)ノ ]],
  },

  {
    [[                                                    ]],
    [[ ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗ ]],
    [[ ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║ ]],
    [[ ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║ ]],
    [[ ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║ ]],
    [[ ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║ ]],
    [[ ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝ ]],
  },

  {
    [[                                __                 ]],
    [[   ___     ___    ___   __  __ /\_\    ___ ___     ]],
    [[  / _ `\  / __`\ / __`\/\ \/\ \\/\ \  / __` __`\   ]],
    [[ /\ \/\ \/\  __//\ \_\ \ \ \_/ |\ \ \/\ \/\ \/\ \  ]],
    [[ \ \_\ \_\ \____\ \____/\ \___/  \ \_\ \_\ \_\ \_\ ]],
    [[  \/_/\/_/\/____/\/___/  \/__/    \/_/\/_/\/_/\/_/ ]],
  },
}
local header_lines = headers[math.random(#headers)]
local header = table.concat(header_lines, "\n") .. "\nHave a nice day!"

local starter = require("mini.starter")
local items = {
  starter.sections.builtin_actions(),
  starter.sections.recent_files(5, true),
  { name = "Find files", action = "lua require('fzf-lua').files()",                                  section = "Custom" },
  { name = "Lazy",       action = "Lazy",                                                            section = "Custom" },
  { name = "Mason",      action = "Mason",                                                           section = "Custom" },
  { name = "Config",     action = "lua require('fzf-lua').files({ cwd = '$XDG_CONFIG_HOME/nvim' })", section = "Custom" },
  { name = "Scratch",    action = "ene | setlocal buftype=nofile",                                   section = "Custom" },
}

local function get_footer()
  local stats = require("lazy").stats()
  local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
  return "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    local stats = require("lazy").stats()
    local ms = (math.floor(stats.startuptime * 100 + 0.5) / 100)
    local footer = "⚡ Neovim loaded " .. stats.count .. " plugins in " .. ms .. "ms"
    if _G.MiniStarter then
      MiniStarter.config.footer = footer
      MiniStarter.refresh()
    end
  end,
})

return {
  evaluate_single = true,
  header = header,
  items = items,
  footer = get_footer
}
