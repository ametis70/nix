return {
	{
		"echasnovski/mini.nvim",
		branch = "stable",
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
			require("leap").add_default_mappings()
		end,
	},
	"dhruvasagar/vim-table-mode",
	"tpope/vim-eunuch",
	{
		"ThePrimeagen/refactoring.nvim",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-treesitter/nvim-treesitter",
		},
		config = true,
	},
}
