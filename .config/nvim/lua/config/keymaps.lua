--Most keymaps will be set in the plugin file to which they correspond
--However we will set a few here from a global perspective

vim.keymap.set("n","<Esc>","<cmd>nohlsearch<CR>",{desc = "Clear search highlights"}) --Clear highlights on search with Esc when in normal mode
vim.keymap.set("n","<leader>q",vim.diagnostic.setloclist,{desc = "Open Diagnostics [Q]uickfix list"})

vim.keymap.set("n","<C-Left>","<C-w><C-h>",{desc = "Move Focus to the left window" })
vim.keymap.set("n","<C-Right>","<C-w><C-l>",{desc = "Move focus to the right window"})
vim.keymap.set("n","<C-Up>","<C-w><C-k>",{desc = "Move focus to the upper window"})
vim.keymap.set("n","<C-Down>","<C-w><C-j>",{desc = "Move focus to the lower window"})

vim.keymap.set("n","-","<cmd>Oil --float<CR>",{desc = "Open Parent Directory in Oil"})
