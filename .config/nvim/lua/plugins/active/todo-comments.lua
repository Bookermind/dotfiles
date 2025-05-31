-- NOTE: keywords are case sensitive!!!!!
return{
    "folke/todo-comments.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim"
    },
    --Examples
    -- TODO: Something I need to do
    -- HACK: This is a nasty hack
    -- PERF: This code is perfect
    -- WARN: This is a warning
    -- BUG: This is a bug - FIXME 
    -- NOTE: This is a note
    opts = {
        signs = true,
        keywords = {
            FIX = {
                color = "error",
                alt = {"FIXME","BUG","FIXIT","FIXTHIS","ISSUE"},
            },
            TODO = {
                color = "todo",
            },
            HACK = {
                color = "hack",
                alt = {"HACKY","NASTY"}
            },
            WARN = {
                color = "warning",
                alt = {"WARNING","XXX"}
            },
            PERF = {
                color = "good",
                alt = {"GOOD","PERFECT"},
            },
            NOTE = {
                color = "note",
                alt = {"INFO"}
            },
        },
        gui_style = {
            fg = "BOLD",
        },
        colors = {
            error = { "#d20f39" },
            todo = {"#fe640b"},
            warning = {"#df8e1d"},
            hack = {"#e64553"},
            info = {"#209fb5"},
            note = {"#1e66f5"},
            good = {"#40a02b"},
        },
    },
}
