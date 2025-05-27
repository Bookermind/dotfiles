return {
	"iamcco/markdown-preview.nvim",
	cmd = { "MarkdownReviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
	build = "cd app && npm install",
	init = function()
		vim.g.mkdp_filetypes = { "markdown" }
	end,
	ft = { "markdown" },
	vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreview<CR>", { desc = "Start [M]arkdown [P]review" }),
}
