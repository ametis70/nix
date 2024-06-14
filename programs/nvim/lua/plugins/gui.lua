local setup_indent_blankline = function()
	vim.opt.list = false
	vim.opt.listchars:append("space:⋅")
	vim.opt.listchars:append("eol:↴")
	vim.opt.listchars:append("tab:⟶ ")

	require("ibl").setup()

	local wk = require("which-key")

	wk.register({
		t = {
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
	require("zen-mode").setup()

	local wk = require("which-key")

	wk.register({
		t = {
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
	})

	local wk = require("which-key")

	wk.register({
		t = {
			t = { "<cmd>Twilight<CR>", "Twilight" },
		},
	}, {
		prefix = "<leader>",
	})
end

return {
	{ "stevearc/dressing.nvim", event = "VeryLazy" },
	{
		"lukas-reineke/indent-blankline.nvim",
		event = "VeryLazy",
		init = setup_indent_blankline,
		dependencies = { "nvim-treesitter/nvim-treesitter" },
	},
	{ "folke/zen-mode.nvim", init = setup_zen_mode },
	{ "folke/twilight.nvim", init = setup_twilight },
	{ "folke/todo-comments.nvim", event = "BufRead", requires = "nvim-lua/plenary.nvim", config = true },
	{ "nvim-tree/nvim-web-devicons", opts = { default = true } },
	{ "norcalli/nvim-colorizer.lua", event = "BufRead" },
}
