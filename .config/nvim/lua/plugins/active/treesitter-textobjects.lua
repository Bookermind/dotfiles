return {
	"nvim-treesitter/nvim-treesitter-textobjects",
	dependencies = {
		"nvim-treesitter/nvim-treesitter",
	},
	init = function()
		local config = require("nvim-treesitter.configs")
		config.setup({
			textobjects = {
				select = {
					enable = true,
					lookahead = true, --Automatically jump forward to textobject
					keymaps = {
						["af"] = { query = "@function.outer", desc = "Select outer part of function" },
						["if"] = { query = "@function.inner", desc = "Select inner part of function" },
						["ac"] = { query = "@class.outer", desc = "Select outer part of class" },
						["ao"] = { query = "@comment.outer", desc = "Select outer part of comment" },
						["ic"] = { query = "@class.inner", desc = "Select inner part of class" },
					},
					selection_modes = {
						["@parameter.outer"] = "v",
						["@function.outer"] = "V",
						["@class.outer"] = "<c-v>",
					},
					include_surrounding_whitespace = true,
				},
				swap = {
					enable = true,
					swap_next = {
						["<leader>a"] = { query = "@parameter.inner", desc = "Swap with next parameter" },
					},
					swap_previous = {
						["<leader>A"] = { query = "@parameter.inner", desc = "Swap with previous parameter" },
					},
				},
				move = {
					enable = true,
					set_jumps = true,
					goto_next_start = {
						["nf"] = { query = "@function.outer", desc = "Goto start of next function" },
					},
					goto_previous_start = {
						["pf"] = { query = "@function.outer", desc = "Goto start of previous function" },
					},
				},
			},
		})
	end,
}
