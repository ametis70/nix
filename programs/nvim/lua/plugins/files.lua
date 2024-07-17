return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    config = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
      {
        "s1n7ax/nvim-window-picker",
        version = "2.*",
        config = function()
          require("window-picker").setup({
            filter_rules = {
              include_current_win = false,
              autoselect_one = true,
              bo = {
                filetype = { "neo-tree", "neo-tree-popup", "notify" },
                buftype = { "terminal", "quickfix" },
              },
            },
          })
        end,
      },
    },
    opts = {
      close_if_last_window = true,
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = true,
          leave_dirs_open = true,
        },
        filtered_items = {
          visible = true,
        },
      },
      window = {
        mappings = {
          ["/"] = "none",
        },
      },
    },
    init = function()
      local wk = require("which-key")

      wk.register({
        o = {
          p = { "<cmd>Neotree toggle<CR>", "Toggle project sidebar" },
        },
      }, {
        prefix = "<leader>",
      })
    end,
  },
  {
    "kevinhwang91/rnvimr",
    init = function()
      local wk = require("which-key")

      wk.register({
        f = {
          r = { "<cmd>RnvimrToggle<CR>", "Toggle Ranger" },
        },
      }, {
        prefix = "<leader>",
      })

      vim.g.rnvimr_enable_ex = 0
      vim.g.rnvimr_enable_picker = 1
      vim.g.rnvimr_enable_bw = 0
    end,
    cmd = "RnvimrToggle",
  },
}
