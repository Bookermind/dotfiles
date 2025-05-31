return {
	"stevearc/conform.nvim",
	opts = {
		formatters_by_ft = {
			lua = { "stylua" },
			yaml = { "yamlfmt" },
			cpp = { "clang-format" },
			python = { "isort", "black" },
			sql = { "sqlfmt" },
			rust = { "rustfmt", lsp_format = "fallback" },
			javascript = { "prettierd", "pretter", stop_after_first = true },
			typescript = { "prettierd", "pretter", stop_after_first = true },
		},
		format_on_save = {
			timeout_ms = 500,
			lsp_format = "fallback",
		},
	},
	vim.keymap.set("n", "<leader>cf", function()
		require("conform").format({ lsp_format = "fallback" })
	end, { desc = "[C]ode [F]ormat" }),
}
