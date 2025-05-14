return {
	"ibhagwan/fzf-lua",
	dependencies = {"nvim-tree/nvim-web-devicons"},
	opts = {},
	keys = {
		{ 
			"<leader>ff", 
			function() require('fzf-lua').files() end, 
			desc="[F]ind [F]iles in current working directory"
		},
		{
			"<leader>fg",
			function() require('fzf-lua').live_grep() end,
			desc="[Find] and [G]rep through the project directory"
		},
		{
			"<leader>fc",
			function() require('fzf-lua').files({cwd=vim.fn.stdpath("config")}) end,
			desc="[F]ind files in the neovim [C]onfig directory"
		}
	}
}
