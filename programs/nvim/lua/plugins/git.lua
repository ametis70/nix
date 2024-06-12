return {
  {
    "pwntester/octo.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "nvim-tree/nvim-web-devicons",
    },
    cmd = "Octo",
    config = true,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-telescope/telescope.nvim",
      "sindrets/diffview.nvim",
    },
    cmd = "Neogit",
    config = true,
  },
  {
    "lewis6991/gitsigns.nvim",
    config = true,
    event = "BufRead",
  },
  {
    "f-person/git-blame.nvim",
    cmd = { "GitBlameToggle", "GitBlameEnable", "GitBlameDisable", "GitBlameOpenCommitURL" },
    init = function()
      local wk = require("which-key")

      vim.g.gitblame_enabled = 0
      local wk_toggle_git_blame = { "<cmd>GitBlameToggle<CR>", "Toggle git blame" }

      wk.register({
        t = {
          b = wk_toggle_git_blame,
        },
        g = {
          n = { "<cmd>Neogit<CR>", "Neogit status" },
          f = { "<cmd>Git<CR>", "Fugitive status" },
          b = wk_toggle_git_blame,
        },
      }, {
        prefix = "<leader>",
      })
    end,
  },
  {
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
  },
}
