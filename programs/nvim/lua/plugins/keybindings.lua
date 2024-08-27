local config = function()
  local wk = require("which-key")

  wk.register({
    f = {
      name = "File",
      C = {
        function()
          vim.api.nvim_input(":Copy " .. vim.fn.expand("%"))
        end,
        "Copy file",
      },
      R = {
        function()
          vim.api.nvim_input(":Move " .. vim.fn.expand("%"))
        end,
        "Rename/move file",
      },
      D = {
        function()
          vim.api.nvim_input(":Delete")
        end,
        "Delete file",
      },
      p = {
        name = "Print",
        a = {
          function()
            print(vim.fn.expand("%:p"))
          end,
          "Print absolute path",
        },
        r = {
          function()
            print(vim.fn.expand("%"))
          end,
          "Print relative path",
        },
      },
      y = {
        name = "Yank",
        a = {
          function()
            vim.fn.setreg("+", vim.fn.expand("%:p"))
          end,
          "Yank absolute path",
        },
        r = {
          function()
            vim.fn.setreg("+", vim.fn.expand("%"))
          end,
          "Yank relative path",
        },
      },
    },
    b = {
      name = "Buffer",
      d = { "<cmd>bdel<CR>", "Delete buffer" },
      s = { "<cmd>write<CR>", "Save buffer" },
      D = {
        function()
          local current_buf = vim.fn.bufnr()
          local current_win = vim.fn.win_getid()
          local bufs = vim.fn.getbufinfo({ buflisted = 1 })
          for _, buf in ipairs(bufs) do
            if buf.bufnr ~= current_buf then
              vim.cmd("silent! bdelete " .. buf.bufnr)
            end
          end
          vim.fn.win_gotoid(current_win)
        end,
        "Delete all buffers except this",
      },
    },
    c = {
      name = "Code",
    },
    h = {
      name = "Help",
    },
    p = {
      name = "Project",
    },
    n = {
      name = "Note",
    },
    T = {
      name = "Toggle",
    },
    t = {
      name = "Test",
    },
    g = {
      name = "Git",
    },
    r = {
      name = "Run",
    },
    o = {
      name = "Open",
      t = { '<cmd>exe v:count1 . "ToggleTerm"<CR>', "Open terminal" },
      T = { "<cmd>terminal<CR>", "Open terminal here" },
    },
    w = {
      name = "Window",
      d = { "<cmd>close<CR>", "Close window" },
      v = { "<cmd>vsplit<CR>", "Vertical split" },
      s = { "<cmd>split<CR>", "Horizontal split" },
    },
    q = {
      name = "Quit",
      q = { "<cmd>qa<CR>", "Quit nvim" },
    },
  }, {
    prefix = "<leader>",
  })
end

return {
  "folke/which-key.nvim",
  lazy = false,
  config = config,
}
