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
vim.o.lazyredraw = false
vim.o.undofile = true
vim.o.mouse = "a"
vim.o.scrolloff = 10
vim.o.laststatus = 3
vim.o.termguicolors = true
vim.opt.list = false
vim.opt.listchars:append("space:⋅")
vim.opt.listchars:append("eol:↴")
vim.opt.listchars:append("tab:⟶ ")

-- Neovide
if vim.g.neovide then
  vim.api.nvim_set_keymap("v", "<D-c>", '"+y', { noremap = true })
  vim.api.nvim_set_keymap("v", "<sc-c>", '"+y', { noremap = true })

  vim.api.nvim_set_keymap("c", "<D-v>", "<c-r>+", { noremap = true })
  vim.api.nvim_set_keymap("c", "<sc-v>", "<c-r>+", { noremap = true })

  vim.api.nvim_set_keymap("i", "<D-v>", "<c-r>+", { noremap = true })
  vim.api.nvim_set_keymap("i", "<sc-v>", "<c-r>+", { noremap = true })

  vim.api.nvim_set_keymap("t", "<D-v>", '<C-\\><C-n>"+Pi', { noremap = true })
  vim.api.nvim_set_keymap("t", "<sc-v>", '<C-\\><C-n>"+Pi', { noremap = true })

  vim.g.neovide_scale_factor = 1.0
  local change_scale_factor = function(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  vim.keymap.set("n", "<C-=>", function()
    change_scale_factor(1.25)
  end)
  vim.keymap.set("n", "<C-->", function()
    change_scale_factor(1 / 1.25)
  end)

  local padding = 16
  vim.g.neovide_padding_top = padding
  vim.g.neovide_padding_bottom = padding
  vim.g.neovide_padding_right = padding
  vim.g.neovide_padding_left = padding
end

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
