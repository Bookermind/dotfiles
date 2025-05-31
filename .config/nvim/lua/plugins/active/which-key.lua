return {
    "folke/which-key.nvim",
    event = "VimEnter",
    opts = {
        delay = 0,
        icons = {
            mappings = vim.g.have_nerd_font,
        },
    },
    keys = {
        {
        "<leader>?",function() require("which-key").show({global=false}) end, desc = "Show Keymaps (which-key)",
        },
    },
}
