return {
	"binhtran432k/dracula.nvim",
	name = dracula,
	lazy = false,
	priority = 1000,
	config = function()
		require("dracula").setup({
			style = "default",
			styles = {
				comments = { italic = true },
				keywords = { italic = false },
				sidebars = "dark",
				floats = "dark",
			},
		})
		vim.cmd("colorscheme dracula")
	end,
}
