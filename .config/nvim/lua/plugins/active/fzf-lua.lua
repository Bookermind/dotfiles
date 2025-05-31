return {
	"ibhagwan/fzf-lua",
	dependencies = { "echasnovski/mini.icons" },
	opts = {},
	keys = {
		{
			"<leader>ff",
			function()
				require("fzf-lua").files()
			end,
			desc = "[F]ind [F]iles in current working directory",
		},
		{
			"<leader>fg",
			function()
				require("fzf-lua").live_grep()
			end,
			desc = "[F]ind and [G]rep through the project directory",
		},
		{
			"<leader>fc",
			function()
				require("fzf-lua").files({ cwd = vim.fn.stdpath("config") })
			end,
			desc = "[F]ind files in the neovim [C]onfig directory",
		},
		{
			"<leader>fk",
			function()
				require("fzf-lua").keymaps()
			end,
			desc = "[F]ind [K]eymaps",
		},
		{
			"<leader>fb",
			function()
				require("fzf-lua").builtin()
			end,
			desc = "[F]ind [B]uiltin fuzzy finders",
		},
		{
			"<leader><leader>",
			function()
				require("fzf-lua").buffers()
			end,
			desc = "Find existing buffers",
		},
		{
			"<leader>fgb",
			function()
				require("fzf-lua").git_branches()
			end,
			desc = "[F]ind [G]it [B]ranches",
		},
		{
			"<leader>fw",
			function()
				require("fzf-lua").grep_cWORD()
			end,
			desc = "[F]ind current [W]ord",
		},
		{
			"<leader>fh",
			function()
				require("fzf-lua").helptags()
			end,
			desc = "[F]ind in the neovim [H]elp",
		},
	},
}
