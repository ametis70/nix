local setup_indent_blankline = function()
  vim.opt.list = false
  vim.opt.listchars:append("space:⋅")
  vim.opt.listchars:append("eol:↴")
  vim.opt.listchars:append("tab:⟶ ")

  require("ibl").setup()

  local wk = require("which-key")

  wk.register({
    T = {
      i = {
        function()
          if vim.opt.list then
            vim.opt.list = false
          else
            vim.opt.list = true
          end
        end,
        "Whitespace characters",
      },
    },
  }, {
    prefix = "<leader>",
  })
end

local setup_zen_mode = function()
  require("zen-mode").setup({
    window = {
      backdrop = 1,
      width = 120,
      height = 1,
      options = {
        signcolumn = "no",
        number = false,
        relativenumber = false,
        -- cursorline = false,
        -- cursorcolumn = false,
        foldcolumn = "0",
        list = false,
      },
    },
    plugins = {
      options = {
        enabled = true,
        ruler = true,
        showcmd = true,
        laststatus = 0,
      },
      twilight = { enabled = true },
      gitsigns = { enabled = true },
      neovide = {
        enabled = true,
        scale = 1.2,
      },
      kitty = {
        enabled = true,
        font = "+4",
      },
    },
  })
end

local init_zen_mode = function()
  local wk = require("which-key")

  wk.register({
    T = {
      z = { "<cmd>ZenMode<CR>", "Zen mode" },
    },
  }, {
    prefix = "<leader>",
  })
end

local setup_twilight = function()
  require("twilight").setup({
    treesitter = true,
    expand = {
      "function",
      "method",
      "table",
      "if_statement",
    },
    context = 1,
  })
end

local init_twilight = function()
  local wk = require("which-key")

  wk.register({
    T = {
      t = { "<cmd>Twilight<CR>", "Twilight" },
    },
  }, {
    prefix = "<leader>",
  })
end

local config_noice = function()
  local noice = require("noice")
  noice.setup({
    lsp = {
      override = {
        ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
        ["vim.lsp.util.stylize_markdown"] = true,
        ["cmp.entry.get_documentation"] = true, -- requires hrsh7th/nvim-cmp
      },
    },
    presets = {
      lsp_doc_border = true,
      command_palette = true,
      bottom_search = true,
    },
    popupmenu = {
      enabled = true,
      backend = "cmp",
    },
  })
end

return {
  { "stevearc/dressing.nvim",      event = "VeryLazy" },
  {
    "lukas-reineke/indent-blankline.nvim",
    event = "VeryLazy",
    init = setup_indent_blankline,
    dependencies = { "nvim-treesitter/nvim-treesitter" },
  },
  {
    "folke/zen-mode.nvim",
    cmd = "ZenMode",
    init = init_zen_mode,
    config = setup_zen_mode,
  },
  {
    "folke/twilight.nvim",
    cmd = "Twilight",
    init = init_twilight,
    config = setup_twilight,
  },
  { "folke/todo-comments.nvim",    event = "BufRead",        requires = "nvim-lua/plenary.nvim", config = true },
  { "nvim-tree/nvim-web-devicons", opts = { default = true } },
  { "norcalli/nvim-colorizer.lua", event = "BufRead" },
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    config = config_noice,
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
  },
}
