return {
	"catppuccin/nvim",
	lazy = false,
	name = catppuccin,
	config = function()
		require("catppuccin").setup({
			flavour = "macchiato",
			transparent_background = true,
			show_end_of_buffer = true,
			styles = {
				comments = { "italic" },
				conditionals = { "bold" },
			},
			integrations = {},
		})
		vim.cmd("colorscheme catppuccin")
	end,
}
