local init = function()
  local wk = require("which-key")

  local run_current_test_keybiding = {
    function()
      require("neotest").run.run()
    end,
    "Run nearest test",
  }

  local keybindings = {
    name = "Test",
    t = run_current_test_keybiding,
    f = {
      function()
        require("neotest").run.run(vim.fn.expand("%"))
      end,
      "Run file tests",
    },
    d = {
      function()
        require("neotest").run.run({ strategy = "dap" })
      end,
      "Debug nearest test",
    },
    T = {
      function()
        require("neotest").run.stop()
      end,
      "Stop running test",
    },
    a = {
      function()
        require("neotest").run.attach()
      end,
      "Attach to running test",
    },
    w = {
      function()
        require("neotest").watch.watch()
      end,
      "Watch nearest test",
    },
    o = {
      function()
        require("neotest").output.open({ enter = true })
      end,
      "Show test output",
    },
    p = {
      function()
        require("neotest").output_panel.toggle()
      end,
      "Toggle output panel",
    },
    c = {
      function()
        require("neotest").output_panel.clear()
      end,
      "Clear output panel",
    },
    s = {
      function()
        require("neotest").summary.toggle()
      end,
      "Toggle summary panel",
    },
  }

  wk.register({
    t = keybindings,
    c = {
      T = keybindings,
    },
  }, {
    prefix = "<leader>",
  })
end

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-neotest/nvim-nio",
      "nvim-treesitter/nvim-treesitter",
      "nvim-neotest/neotest-jest",
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
    },
    init = init,
    config = function()
      require("neotest").setup({
        adapters = {
          require("neotest-jest"),
          require("neotest-python"),
          require("neotest-go"),
        },
      })
    end,
  },
}
