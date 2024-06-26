return {
  {
    "echasnovski/mini.nvim",
    branch = "stable",
    event = "BufRead",
    config = function()
      require("mini.jump").setup({})
      require("mini.bufremove").setup({})
    end,
  },
  {
    "ggandor/leap.nvim",
    dependencies = {
      "tpope/vim-repeat",
    },
    config = function()
      require("leap").add_default_mappings(true)
    end,
    event = "BufRead",
  },
  {
    "dhruvasagar/vim-table-mode",
    cmd = "TableModeToggle",
  },
  {
    "tpope/vim-eunuch",
    cmd = {
      "Remove",
      "Delete",
      "Move",
      "Chmod",
      "Mkdir",
      "Cfind",
      "Clocate",
      "Lfind",
      "Llocate",
      "Wall",
      "SudoWrite",
      "SudoEdit",
    },
  },
  {
    "ThePrimeagen/refactoring.nvim",
    cmd = "Refactor",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = true,
  },
}
