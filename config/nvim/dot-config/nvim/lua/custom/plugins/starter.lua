return {
  {
    "goolord/alpha-nvim",
    config = function()
      -- Get the default dashboard configuration
      local dashboard = require 'custom.starter'
      -- Apply the customized configuration
      require 'alpha'.setup(dashboard.config)
    end,
  }
}
