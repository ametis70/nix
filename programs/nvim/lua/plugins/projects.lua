return {
  {
    -- "ahmedkhalf/project.nvim",
    "hawk78/project.nvim",
    config = function(_, opts)
      require("project_nvim").setup(opts)
    end,
    opts = {
      manual_mode = true,
      detection_methods = { "lsp", "pattern" },
      patterns = {
        ".git",
        "Makefile",
        "package.json",
        ".luarc.json",
        "lazy-lock.json",
        ".zk",
      },
      ignore_lsp = {},
      exclude_dirs = {},
      show_hidden = true,
      silent_chdir = true,
      datapath = vim.fn.stdpath("data"),
    },
  },
}
