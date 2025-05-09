return {
	"catppuccin/nvim",
	lazy = false,
	name = catppuccin,
	config = function()
		require("catppuccin").setup({
			flavour = "macchiato",
		});
		vim.cmd("colorscheme catppuccin");
	end,
}
