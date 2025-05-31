-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
	local lazyrepo = "https://github.com/folke/lazy.nvim.git"
	local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
	if vim.v.shell_error ~= 0 then
		vim.api.nvim_echo({
			{ "Failed to clone lazy.nvim:\n", "ErrorMsg" },
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
--Load Global (non-plugin specific) keymaps
require("config.keymaps")

-- Setup lazy.nvim
require("lazy").setup({
	spec = {
		-- import your plugins
		-- My plugins live in the nvim/lua/plugins/active directory
		-- Allows me to move files into the nvim/lua/plugins/inactive directory to retain them my have nvim ignore them
		-- Could use the enabled = false in the plugin spec but this keeps the directory from getting cluttered!
		{ import = "plugins.active" },
	},
	install = { colorscheme = { "catppuccin" } },
	checker = { enabled = true, notify = true },
	ui = {
		border = "rounded",
		backdrop = 0,
	},
})

--Some functions and/or autocmds may depend on plugins so for safety we will load functions anfter the above lazy plugin load
--Load functions and autocommands
require("config.functions")
