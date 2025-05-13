return {
	"nvim-lualine/lualine.nvim",
	dependencies = {"nvim-tree/nvim-web-devicons", opt = true},
	name = lualine,
	config = function()
		require("lualine").setup({
			options = {
				theme = "catppuccin"
			}
		});
	end;
}

