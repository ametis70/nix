return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    cmd = "Neotree",
    config = true,
    opts = {
      filesystem = {
        use_libuv_file_watcher = true,
        follow_current_file = {
          enabled = false, -- This will find and focus the file in the active buffer every time
        },
      },
    },
    init = function()
      local wk = require("which-key")

      wk.register({
        o = {
          p = { "<cmd>Neotree<CR>", "Open project sidebar" },
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
