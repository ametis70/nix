local init_zk = function()
  require("telescope").load_extension("zk")

  local wk = require("which-key")

  wk.register({
    n = {
      n = {
        function()
          vim.ui.input({ prompt = "Note title: " }, function(input)
            require("zk.commands").get("ZkNew")({ title = input })
          end)
        end,
        "Create new note",
      },
      d = {
        function()
          require("zk.commands").get("ZkNew")({ dir = "journal" })
        end,
        "Create or edit daily note",
      },
      f = {
        function()
          require("zk.commands").get("ZkNotes")()
        end,
        "Find note",
      },
      i = {
        function()
          require("zk.commands").get("ZkIndex")()
        end,
        "Index notes",
      },
      t = {
        function()
          require("zk.commands").get("ZkTag")()
        end,
        "Search by tag",
      },
    },
  }, {
    prefix = "<leader>",
  })

  local augroup = vim.api.nvim_create_augroup("MarkdownZk", {})
  local ZK_NOTEBOOK_DIR = vim.env.ZK_NOTEBOOK_DIR or vim.env.HOME .. ".zk"
  local patt = { ZK_NOTEBOOK_DIR .. "/*.md" }

  vim.api.nvim_clear_autocmds({ group = augroup })
  vim.api.nvim_create_autocmd("BufEnter", {
    group = augroup,
    pattern = patt,
    callback = function(bufnr)
      vim.cmd("lcd %:p:h")

      wk.register({
        t = {
          function()
            require("zk.commands").get("ZkNewFromTitleSelection")()
          end,
          "New note (selected as title)",
        },
        c = {
          function()
            require("zk.commands").get("ZkNewFromContentSelection")()
          end,
          "New note (selected as content)",
        },
        m = {
          function()
            require("zk.commands").get("ZkMatch")()
          end,
          "Find note match",
        },
        i = {
          function()
            require("zk").pick_notes(nil, nil, function(notes)
              local vstartr, vstartc = unpack(vim.api.nvim_win_get_cursor(0))
              local _, vendr, vendc, _ = unpack(vim.fn.getpos("v"))

              local link = "[" .. notes[1].title .. "](" .. notes[1].path .. ")"
              print(vstartr, vstartc, vendr, vendc, vstartc + #link)

              vim.api.nvim_buf_set_text(0, vstartr - 1, vstartc - 2, vendr - 1, vendc, { link })
              vim.api.nvim_win_set_cursor(0, { vendr, vstartc + #link - 3 })
            end)
          end,
          "Insert note link",
        },
      }, {
        mode = "v",
        bufnr = bufnr,
        prefix = "<localleader>",
      })

      wk.register({
        b = {
          function()
            require("zk.commands").get("ZkBacklinks")()
          end,
          "Show note backlinks",
        },
        l = {
          function()
            require("zk.commands").get("ZkLinks")()
          end,
          "Show note links",
        },
        i = {
          function()
            require("zk").pick_notes(nil, nil, function(notes)
              local cur = vim.api.nvim_win_get_cursor(0)
              local link = "[" .. notes[1].title .. "](" .. notes[1].path .. ")"
              vim.api.nvim_buf_set_text(0, cur[1] - 1, cur[2], cur[1] - 1, cur[2], { link })
              vim.api.nvim_win_set_cursor(0, { cur[1], cur[2] + #link })
            end)
          end,
          "Insert note link",
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
  {
    "jakewvincent/mkdnflow.nvim",
    rocks = "luautf8",
    Event = "BufEnter *.md",
    opts = {
      mappings = {
        MkdnEnter = { { "n", "v" }, "<CR>" },
        MkdnTab = false,
        MkdnSTab = false,
        MkdnNextLink = { "n", "<Tab>" },
        MkdnPrevLink = { "n", "<S-Tab>" },
        MkdnNextHeading = { "n", "]]" },
        MkdnPrevHeading = { "n", "[[" },
        MkdnGoBack = { "n", "<BS>" },
        MkdnGoForward = { "n", "<Del>" },
        MkdnCreateLink = false,                                  -- see MkdnEnter
        MkdnCreateLinkFromClipboard = { { "n", "v" }, "<leader>p" }, -- see MkdnEnter
        MkdnFollowLink = false,                                  -- see MkdnEnter
        MkdnDestroyLink = { "n", "<M-CR>" },
        MkdnTagSpan = { "v", "<M-CR>" },
        MkdnMoveSource = { "n", "<F2>" },
        MkdnYankAnchorLink = { "n", "ya" },
        MkdnYankFileAnchorLink = { "n", "yfa" },
        MkdnIncreaseHeading = { "n", "+" },
        MkdnDecreaseHeading = { "n", "-" },
        MkdnToggleToDo = { { "n", "v" }, "<C-Space>" },
        MkdnNewListItem = false,
        MkdnNewListItemBelowInsert = { "n", "o" },
        MkdnNewListItemAboveInsert = { "n", "O" },
        MkdnExtendList = false,
        -- MkdnUpdateNumbering = { "n", "<leader>nn" },
        MkdnUpdateNumbering = false,
        MkdnTableNextCell = { "i", "<Tab>" },
        MkdnTablePrevCell = { "i", "<S-Tab>" },
        MkdnTableNextRow = false,
        MkdnTablePrevRow = { "i", "<M-CR>" },
        MkdnTableNewRowBelow = { "n", "<leader>ir" },
        MkdnTableNewRowAbove = { "n", "<leader>iR" },
        MkdnTableNewColAfter = { "n", "<leader>ic" },
        MkdnTableNewColBefore = { "n", "<leader>iC" },
        MkdnFoldSection = { "n", "<leader>f" },
        MkdnUnfoldSection = { "n", "<leader>F" },
      },
    },
  },

  {
    "ekickx/clipboard-image.nvim",
    cmd = "PasteImg",
    opts = {
      default = {
        img_dir = { "%:p:h", "img" },
        img_name = function()
          vim.fn.inputsave()
          local name = vim.fn.input("Name: ")
          vim.fn.inputrestore()
          return name
        end,
      },
    },
  },
  {
    "mickael-menu/zk-nvim",
    init = init_zk,
    config = function(_, opts)
      require("zk").setup(opts)
    end,
    opts = {
      picker = "telescope",
    },
    dependencies = {
      "nvim-telescope/telescope.nvim",
    },
  },
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    ---@type snacks.Config
    opts = {
      image = {
        enabled = true,
        doc = {
          enabled = true,
          inline = false,
          float = true,
        },
      },
    },
  },
}
