return {
	{
		"antosha417/nvim-lsp-file-operations",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-neo-tree/neo-tree.nvim",
		},
		config = function()
			require("lsp-file-operations").setup()
		end,
	},
	{
		"nvim-neo-tree/neo-tree.nvim",
		branch = "v3.x",
		dependencies = {
			"nvim-lua/plenary.nvim",
			"nvim-tree/nvim-web-devicons",
			"MunifTanjim/nui.nvim",
			--       {
			--           "3rd/image.nvim",
			--           opts = {}
			--       },
		},
		lazy = false,
		-----@module "neo-tree",
		-----@type neotree.Config?
		config = function()
			require("neo-tree").setup({
				enable_git_status = true,
				enable_diagnostics = true,
				sort_case_insensitive = false,
				default_component_configs = {
					container = {
						enable_character_fade = true,
					},
					name = {
						use_git_status_colors = true,
						highlight = "NeoTreeFileName",
					},
					filesystem = {
						filtered_items = {
							hide_dotfiles = false,
							visible = true,
						},
					},
				},
			})
			vim.keymap.set(
				"n",
				"<leader>e",
				"<Cmd>Neotree reveal=true source=filesystem toggle=true<CR>",
				{ desc = "Open Neotree" }
			)
		end,
	},
}
