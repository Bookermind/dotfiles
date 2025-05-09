--Indentation Options
vim.opt.expandtab = true	-- Convert Tabs to spaces
vim.opt.shiftwidth = 4		-- Indent by 4 spaces

vim.opt.tabstop = 4
vim.opt.softtabstop = 4

vim.opt.smarttab = true
vim.opt.smartindent = true
vim.opt.autoindent = true
vim.opt.breakindent = true

--Line Numbers
vim.opt.number = true		-- Enable Line Numbers
vim.opt.relativenumber = true

vim.opt.cursorline = true

vim.opt.undofile = true		-- Preserve undos between sessions

vim.opt.mouse = "a"

vim.opt.showmode = false	-- Don't show the mode in the status line (as it's shown in the lualine)

vim.opt.ignorecase = true	-- Case insensitive searchs
vim.opt.smartcase = true

vim.opt.signcolumn = "yes"	-- Keep the sign colum on always (useful for code files)

--Splits configuration
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

vim.opt.scrolloff = 10

