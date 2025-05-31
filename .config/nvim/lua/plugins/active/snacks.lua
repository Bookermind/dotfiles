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
	},
}
