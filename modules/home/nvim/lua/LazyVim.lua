---@diagnostic disable: missing-fields

require("lazy").setup({
	defaults = {
		lazy = false,
		version = false,
	},
	checker = {
		enabled = false,
		notify = false,
	},
	performance = {
		rtp = {
			disabled_plugins = {
				"gzip",
				"tarPlugin",
				"tohtml",
				"tutor",
				"zipPlugin",
			},
		},
	},
	dev = {
		path = vim.g.PLUGINS_PATH,
		patterns = { "" },
		fallback = false,
	},
	spec = {
		{
			{
				"LazyVim/LazyVim",
				import = "lazyvim.plugins",
				opts = { colorscheme = "tokyonight" },
			},
			-- Extras
			{ import = "lazyvim.plugins.extras.lang.clangd" },
			{ import = "lazyvim.plugins.extras.lang.cmake" },
			{ import = "lazyvim.plugins.extras.lang.docker" },
			{ import = "lazyvim.plugins.extras.lang.git" },
			{ import = "lazyvim.plugins.extras.lang.go" },
			{ import = "lazyvim.plugins.extras.lang.json" },
			{ import = "lazyvim.plugins.extras.lang.markdown" },
			{ import = "lazyvim.plugins.extras.lang.nix" },
			{ import = "lazyvim.plugins.extras.lang.python" },
			{ import = "lazyvim.plugins.extras.lang.sql" },
			{ import = "lazyvim.plugins.extras.lang.svelte" },
			{ import = "lazyvim.plugins.extras.lang.tailwind" },
			{ import = "lazyvim.plugins.extras.lang.rust" },
			{ import = "lazyvim.plugins.extras.lang.tex" },
			{ import = "lazyvim.plugins.extras.lang.toml" },
			{ import = "lazyvim.plugins.extras.lang.typescript" },
			{ import = "lazyvim.plugins.extras.lang.vue" },
			{ import = "lazyvim.plugins.extras.lang.yaml" },

			{ import = "lazyvim.plugins.extras.ai.copilot" },
			{ import = "lazyvim.plugins.extras.ai.copilot-chat" },

			{ import = "lazyvim.plugins.extras.coding.yanky" },

			{ import = "lazyvim.plugins.extras.editor.dial" },
			{ import = "lazyvim.plugins.extras.editor.inc-rename" },
			{ import = "lazyvim.plugins.extras.editor.overseer" },

			{ import = "lazyvim.plugins.extras.dap.core" },
			{ import = "lazyvim.plugins.extras.dap.nlua" },

			{ import = "lazyvim.plugins.extras.formatting.black" },
			{ import = "lazyvim.plugins.extras.formatting.prettier" },

			{ import = "lazyvim.plugins.extras.linting.eslint" },

			{ import = "lazyvim.plugins.extras.test.core" },

			{ import = "lazyvim.plugins.extras.util.dot" },
			{ import = "lazyvim.plugins.extras.util.mini-hipatterns" },
			{ import = "lazyvim.plugins.extras.util.rest" },

			-- Colorscheme
			{
				"folke/tokyonight.nvim",
				lazy = true,
				opts = { style = "storm" },
			},

			-- Nix
			{ "williamboman/mason-lspconfig.nvim", enabled = false },
			{ "williamboman/mason.nvim", enabled = false },
			{ "jay-babu/mason-nvim-dap.nvim", enabled = false },
			{
				"nvim-treesitter/nvim-treesitter",
				opts = function(_, opts)
					opts.ensure_installed = {}
				end,
			},
		},
	},
})
