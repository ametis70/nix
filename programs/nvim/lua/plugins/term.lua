local lazygit = nil
local last_cwd = vim.fn.getcwd()

local spawn_lazygit = function()
	local Terminal = require("toggleterm.terminal").Terminal
	return Terminal:new({
		count = 999,
		cmd = "lazygit",
		hidden = true,
		direction = "tab",
		on_open = function(term)
			vim.cmd("startinsert!")
			vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<esc>", "<esc>", { noremap = true, silent = true })
			vim.api.nvim_buf_set_keymap(term.bufnr, "t", "<C-c>", "", {
				callback = function()
					term:toggle()
				end,
				noremap = true,
				silent = true,
			})
		end,
	})
end

local config = function()
	require("toggleterm").setup()
end

local init = function()
	local wk = require("which-key")

	wk.register({
		g = {
			g = {
				function()
					local current_cwd = vim.fn.getcwd()
					if last_cwd ~= current_cwd then
						last_cwd = current_cwd
						if lazygit ~= nil then
							lazygit:shutdown()
						end
						lazygit = nil
					end
					if lazygit == nil then
						lazygit = spawn_lazygit()
					end
					lazygit:toggle()
				end,
				"Open lazygit",
			},
		},
		o = {
			t = { '<cmd>exe v:count1 . "ToggleTerm"<CR>', "Open terminal" },
		},
	}, { prefix = "<leader>" })
end

return {
	"akinsho/toggleterm.nvim",
	version = "*",
	init = init,
	config = config,
	event = "VeryLazy",
	opts = {
		hide_numbers = true,
		shade_terminals = true,
		start_in_insert = true,
		direction = "horizontal",
		close_on_exit = false,
	},
}
