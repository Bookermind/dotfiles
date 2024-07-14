# My Dotfiles
This directory contains my dotfiles managed locally via GNU Stow.  
There is a subdirectory called "scripts" which is not managed by stow.  
This holds arch linux installation notes and package lists.   

## Requirements

```
pacman -S git stow zsh zoxide fzf neovim
apt install git stow zsh zoxide fzf neovim

```

### Installation
Check out the repo in your $HOME directory using git
```
$ git clone https://github.com/Bookermind/dotfiles.git
$ cd dotfiles
```

Use stow to place the dot files into the right locations within the .config directory of your home
```
stow .
```
