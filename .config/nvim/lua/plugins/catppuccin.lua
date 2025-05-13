return {
	"catppuccin/nvim",
	lazy = false,
	name = catppuccin,
	config = function()
		require("catppuccin").setup({
			flavour = "macchiato",
--			flavour = "frappe",
			styles = {
				comments = { "italic" }, -- Change comments to italics
				conditionals = { "italic" },
			},
			integrations = {
				treesitter = true,
--				fzf = true,
				markdown = true
			},
		});
		vim.cmd("colorscheme catppuccin");
	end,
}
