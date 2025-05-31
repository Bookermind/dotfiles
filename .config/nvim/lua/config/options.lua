--Setup Leader and LocalLeader
vim.g.mapleader = " "
vim.g.maplocalleader = " "

--Indentation Options
vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true

--Line number Options
vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.cursorline = true
vim.opt.undofile = true
vim.opt.mouse = "a"
vim.opt.showmode = false
vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.inccommand = "split"					--Preview substitutions as you type
vim.opt.confirm = true						--Ask for confirmation when performing actions that would fail due to unsaved changes in the buffer

--Code relative config
vim.opt.signcolumn = "yes"					--Preserve the gutter at all times
vim.opt.scrolloff = 10						--Preserve 10 rows above and below cursor when scrolling
vim.g.have_nerd_font = true
--See :help 'list'
--and :help 'listchars'
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }	--Configure how non printing charecters display

--Splits configuration
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.termguicolors = true					--Enable 24 bit color (required for nvim-notify)

--Sync noevim's clipboard with the OS's
vim.schedule(function()
	vim.o.clipboard = 'unnamedplus'
end)
