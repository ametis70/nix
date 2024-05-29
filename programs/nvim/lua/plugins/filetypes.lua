local init_orgmode = function()
  local wk = require("which-key")

  vim.api.nvim_create_autocmd("BufEnter", {
    pattern = "*.org",
    callback = function()
      vim.wo.foldexpr = "nvim_treesitter#foldexpr()"
      vim.wo.foldmethod = "expr"
    end,
  })

  local wk_open_org_agenda = {
    [[<cmd>lua require('orgmode').action("agenda.prompt")<CR>]],
    "Org agenda",
  }

  wk.register({
    O = {
      name = "Org mode",
      a = wk_open_org_agenda,
      f = {
        [[<cmd>lua require('telescope.builtin').find_files{ cwd = '~/.org' }<CR>]],
        "Find file in notes",
      },
      n = {
        [[<cmd>lua require('orgmode').action("capture.prompt")<CR>]],
        "Org capture",
      },
      s = {
        [[<cmd>lua require('telescope.builtin').live_grep{ cwd = '~/.org' }<CR>]],
        "Search notes",
      },
    },
  }, {
    prefix = "<leader>",
  })
end

local init_package_info = function()
  local augroup = vim.api.nvim_create_augroup("PackageJson", {})
  local patt = { "package.json" }

  local wk = require("which-key")

  vim.api.nvim_clear_autocmds({ group = augroup })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = patt,
    callback = function(bufnr)
      wk.register({
        s = {
          function()
            require("package-info").toggle()
          end,
          "Toggle package versions",
        },
        d = {
          function()
            require("package-info").delete()
          end,
          "Delete dependency",
        },
        c = {
          function()
            require("package-info").change_version()
          end,
          "Change dependency version",
        },
        a = {
          function()
            require("package-info").install()
          end,
          "Add new dependency",
        },
        u = {
          function()
            require("package-info").update()
          end,
          "Update dependency",
        },
      }, {
        mode = "n",
        bufnr = bufnr,
        prefix = "<localleader>",
      })
    end,
  })
end

return {
  { "RaafatTurki/hex.nvim", config = true },
  "Eduruiz/vim-blade",
  {
    "nvim-orgmode/orgmode",
    opts = {
      org_agenda_files = {
        "~/.org/work/*",
        "~/.org/learning/*",
        "~/.org/projects/*",
        "~/.org/calendars/*",
        "~/.org/conferences/*",
      },
      org_default_notes_file = "~/.org/refile.org",
    },
    init = init_orgmode,
  },
  {
    "vuki656/package-info.nvim",
    dependencies = {
      "MunifTanjim/nui.nvim",
    },
    init = init_package_info,
  },
}
