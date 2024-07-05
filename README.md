# My Dotfiles
This directory contains my dotfiles managed locally via GNU Stow

## Requirements

```
pacman -S git stow
apt install git stow
```

### Installation
Check out the repo in your $HOME directory using git
```
$ git clone git@github.com:Bookermind/dotfiles.git
$ cd dotfiles
```

Use stow to place the dot files into the right locations within the .config directory of your home
```
stow .
```
