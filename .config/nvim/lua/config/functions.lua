--Highlight when yanking text
vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking text",
    group = vim.api.nvim_create_augroup("Highlight-Yank",{clear = true}),
    callback = function()
        vim.hl.on_yank()
    end,
})

--Autoclose lazy when it looses focus
vim.api.nvim_create_autocmd("BufLeave", {
    desc = "Close Lazy when it looses focus",
    group = vim.api.nvim_create_augroup("Lazy-User",{clear = true}),
    callback = function()
        local ft = vim.api.nvim_get_option_value(
            "filetype",
            {buf = vim.api.nvim_get_current_buf()}
        )
        if ft == 'lazy' then
            require("lazy.view").view:close()
        end
    end,
})
