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

local subheaders = {
  "May the code be with you!",
  "AI-powered techincal debt machine",
  "Feeling down? You're not alone!",
  "Be well, be safe, and be happy!",
  "Byte-sized joy, one motion at a time.",
  "PDE, PDE, PDE!",
  "I use arch, btw",
  "Terminal wizardy",
  "Dis' is nothin' but a lua script.",
  "Some can C, a few C sharp — but only a handful C plus-plus.",
  "Welcome back. No, you still don’t need Emacs.",
  "TODO: Fix everything",
  "Trust the muscle memory.",
  "Save early, save often.",
  "Make small changes, but make them relentlessly.",
  "Live, laugh, :wq",
  "Another config tweak? Groundbreaking.",
  "Big plans, huh? Let’s see how long that lasts.",
  "Home is where the init.lua is",
  "You had me at :help",
  "The real code was the typos we made along the way.",
  "Congratulations — you broke Vim again! Productivity just skyrocketed.",
  "One more plugin won’t hurt, right?",
  "Another plugin? Sure — because what you really need is more chaos in your life.",
  "Someday your code will compile. Or the universe will collapse. Either way, exciting times.",
  "Proudly writing tomorrow’s legacy code today.",
  "The bravest soldiers run nightly.",
  "You don’t need motivation. You need coffee.",
  "Whitespace wars: the saga continues.",
  "Remember: nothing is truly deprecated, only forgotten.",
}

local header_lines = headers[math.random(#headers)]
local subheader = subheaders[math.random(#subheaders)]
local header = table.concat(header_lines, "\n") .. "\n" .. subheader

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
  return "⚡ Neovim loaded " .. stats.loaded .. "/" .. stats.count .. " plugins in " .. ms .. "ms"
end

vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    if _G.MiniStarter then
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
