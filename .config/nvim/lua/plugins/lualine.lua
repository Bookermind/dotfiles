return {
	"nvim-lualine/lualine.nvim",
	dependencies = {
		"nvim-tree/nvim-web-devicons",
		opt = true,
	},
	name = lualine,
	config = function()
		require("lualine").setup({
			options = {
				icons_enabled = true,
				theme = "dracula",
				section_separators = { left = "", right = "" },
				disabled_filetypes = { "neo-tree" },
				component_separators = { left = "", right = "" },
			},
			sections = {
				lualine_a = { "mode" },
				lualine_b = { "branch", "diff", "diagnostics" },
				lualine_c = { { "filename", path = 3, shorting_target = 15 } },
				lualine_x = { "encoding", "filetype", "lsp_status" },
				lualine_y = { "progress" },
				lualine_z = { "location" },
			},
		})
	end,
}
