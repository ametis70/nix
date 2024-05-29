return {
  {
    "b0o/incline.nvim",
    config = function()
      require("incline").setup({
        hide = {
          cursorline = true,
        },
      })
    end,
    event = "VeryLazy",
  },
  {
    "hoob3rt/lualine.nvim",
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      options = {
        -- Disable sections and component separators
        component_separators = "",
        section_separators = "",
        disabled_filetypes = { "neo-tree" },
        globalstatus = true,
        theme = "tokyonight",
      },
      sections = {
        -- these are to remove the defaults
        lualine_a = { "mode" },
        lualine_b = { "branch", "diff" },
        lualine_c = {
          {
            "filename",
            condition = function()
              return vim.fn.empty(vim.fn.expand("%:t")) ~= 1
            end,
            path = 1,
          },
        },
        lualine_x = { "location", "progress" },
        lualine_y = { "diagnostics", "filetype" },
        lualine_z = {},
      },
    },
    config = true,
    event = "VeryLazy",
  },
}
