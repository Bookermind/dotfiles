return {
	"folke/snacks.nvim",
	priority = 1000,
	lazy = false,
	---@type = snacks.Config
	opts = {
		indent = {
			enabled = true,
			char = ":",
			only_current = true,
			scope = {
				enabled = true,
				char = ":",
			},
		},
		terminal = {
			enabled = true,
		},
	},
	keys = {
		{
			"<leader>tt",
			function()
				Snacks.terminal()
			end,
			desc = "[T]oggle [T]erminal",
		},
	},
}
