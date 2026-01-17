-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{"Failed to clone lazy.nvim:\n", "ErrorMsg"},
			{ out, "WarningMsg" },
			{ "\nPress any key to exit..." },
		}, true, {})
		vim.fn.getchar()
		os.exit(1)
	end
end
vim.opt.rtp:prepend(lazypath)

-- Set up mapleader and maplocalleader BEFORE loading lazy
require("config.options")
-- Load Glabal (non-plugin specific) keymaps
require("config.keymaps")

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		{import = "plugins"},
	},
	install = { colorscheme = { "dracula" } },
	checker = { enabled = true, notify = true },
	ui = {
		border = "rounded",
		backdrop = 0,
	},
})

--Some functions/autocmds may depend on functionality provided by plugins. For safety we will load functions AFTER lazy plugins
require("config.functions")
