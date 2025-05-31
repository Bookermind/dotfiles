return {
    "stevearc/oil.nvim",
    ---@module 'oil'
    ---@type oil.SetupOpts
    opts = {
        columns = {
            "icon",
            "size",
        },
        float = {
            border = "double",
        },
    },
    dependencies = {
        {
            "echasnovski/mini.icons", opts = {}
        }
    },
    lazy = false,
}
