local init = function()
	local wk = require("which-key")

	local augroup = vim.api.nvim_create_augroup("RestNvim", {})
	vim.api.nvim_clear_autocmds({ group = augroup })
	vim.api.nvim_create_autocmd("BufEnter", {
		group = augroup,
		pattern = { "*.http" },
		callback = function(bufnr)
			wk.register({
				r = {
					"<Plug>rest run",
					"Run the request under the cursor",
				},
				l = { "<Plug>rest run last", "Re-run the last request" },
			}, {
				mode = "n",
				bufnr = bufnr,
				prefix = "<localleader>",
			})
		end,
	})
end

local config = function()
	require("rest-nvim").setup({})
end

return {
	"rest-nvim/rest.nvim",
	init = init,
	config = config,
	event = "BufEnter *.http",
	rocks = { "lua-curl", "nvim-nio", "mimetypes", "xml2lua" },
}
