#!/bin/bash

### Install prerequisite packages
sudo dnf install -y stow zsh zoxide fzf eza podman

### Install fonts (local files)

### Stow dotfiles
stow -t ~ zsh
stow -t ~ starship
stow -t ~ bat
stow -t ~ systemd
stow -t ~ avatar

# Distrobox Assemble
distrobox assemble create --file ~/.config/distrobox/distrobox.ini
