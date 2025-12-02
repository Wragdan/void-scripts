#!/bin/bash

set -e

git clone https://github.com/Wragdan/dotfiles /home/wragdan/.dotfiles
cd /home/wragdan/.dotfiles
git checkout voidlinux

stow x11
stow shell
stow zsh
stow zathura
stow yazi
stow sxhkd
stow starship
stow pulse
stow pipewire
stow picom
stow nvim
stow local
stow mpd
stow ncmpcpp
stow fontconfig
stow eww
stow git

touch /home/wragdan/.config/shell/secrets

echo "Configuring rust - Please select default installation"
rustup-init

echo "Installing node version 22"
fnm install 22
