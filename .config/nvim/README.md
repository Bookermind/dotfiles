# Personal Neovim configuration heavily inspired by MrJakob  
MrJakob's repo for the neovim from scratch series can be found [here](https://github.com/jakobwesthoff/nvim-from-scratch).  
This repo (with my own versions) can be found [here](https://github.com/Bookermind.com/dotfiles)

## Folder Layout  

## Options  
### Indentation Options  
Tabs are converted to spaces  
Indentations are set to four spaces  
SmartTab, SmartIndent, Autoindent and BreakIndent set to true  
### Line Numbers and gutter  
Line Numbers on  
Relative Line Numbers on  
Sign Column (gutter) always on  
### Rendering  
Tabs visible as "» "  
Trailing Spaces as "·"  
Non Breaking Spaces as "␣"  
### Other  
Searchs are case insensative  
Mouse mode is on  
The cursorline is shown  
Scrolling preserves 10 lines above and below the current line  

## Modules and plugins   
- [X] lazy.nvim
- [X] catppuccin.nvim
- [X] lualine.nvim
- [X] oil.nvim
- [X] vim-sleuth
- [X] treesitter.nvimi
- [X] treeesitter-textobjects.nvim
- [X] which-key.nvim
- [X] fzflua
    - [X] fzf cli utility
    - [X] ripgrep cli utility
- [ ] project.nvim (this has been turned off as it doesn't play nicely with the softlinks from GNU stow)  
- [X] LSP
    - [X] Ensure to install npm and unzip on the command line otherwise cerain language servers will not install  
- [ ] blink-cpm.lua
- [X] dressing.nvim
- [X] conform.nvim
