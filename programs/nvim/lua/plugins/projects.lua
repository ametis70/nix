return {
  {
    "coffebar/neovim-project",
    config = function()
      require("neovim-project").setup({
        projects = {
          "~/Sandbox/*",
        },
        last_session_on_startup = false,
        dashboard_mode = true,
      })
    end,
    init = function()
      vim.opt.sessionoptions:append("globals")
    end,
    dependencies = {
      { "nvim-lua/plenary.nvim" },
      { "nvim-telescope/telescope.nvim" },
      { "Shatur/neovim-session-manager" },
    },
    lazy = false,
    priority = 100,
  },
  {
    "Shatur/neovim-session-manager",
    lazy = false,
    config = function()
      local config = require("session_manager.config")
      require("session_manager").setup({
        autoload_mode = config.AutoloadMode.Disabled,
      })
    end,
  },
}
