local indent = 2

vim.cmd("syntax enable")
vim.cmd("filetype plugin indent on")
vim.o.expandtab = true
vim.o.shiftwidth = indent
vim.o.smartindent = false
vim.o.autoindent = true
vim.o.softtabstop = indent
vim.o.tabstop = indent
vim.o.hidden = true
vim.o.wrap = true
vim.o.ignorecase = true
vim.o.scrolloff = 10
vim.o.shiftround = true
vim.o.smartcase = true
vim.o.splitbelow = true
vim.o.splitright = true
vim.o.number = true
vim.o.relativenumber = true
vim.o.cursorline = true
vim.o.clipboard = "unnamed,unnamedplus"
vim.o.lazyredraw = true
vim.o.undofile = true
vim.o.mouse = "a"
vim.o.scrolloff = 10
vim.o.laststatus = 3
vim.o.termguicolors = true
vim.opt.list = false
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab:⟶ ")

vim.g.maplocalleader = ","

-- Highlight on yank
vim.cmd("au TextYankPost * lua vim.highlight.on_yank {on_visual = false}")

-- Terminal
vim.api.nvim_create_augroup("Terminal", { clear = true })
vim.api.nvim_create_autocmd("TermOpen", {
  group = "Terminal",
  pattern = "*",
  callback = function()
    -- vim.bo.filetype = "terminal"
    vim.api.nvim_buf_set_keymap(0, "t", "<esc>", [[<C-\><C-n>]], { noremap = true })
    vim.cmd("startinsert")
  end,
})

vim.g.tokyonight_style = "night"
vim.cmd("colorscheme tokyonight")
