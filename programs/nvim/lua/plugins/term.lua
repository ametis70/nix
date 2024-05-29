local init = function()
	local Terminal = require("toggleterm.terminal").Terminal
	local lazygit = Terminal:new({
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

	local wk = require("which-key")

	wk.register({
		g = {
			g = {
				function()
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
	opts = {
		hide_numbers = true,
		shade_terminals = true,
		start_in_insert = true,
		direction = "horizontal",
		close_on_exit = false,
	},
}
