#!/bin/bash

set -e

sudo wragdan

echo "Cloning personal void-packages"
if [ ! -d "/home/wragdan/void-packages" ] ; then
    git clone https://github.com/Wragdan/void-packages /home/wragdan/void-packages
fi
cd /home/wragdan/void-packages
git checkout wragdan

echo "Starting xbps-src installs"
sleep 10

echo "Bootstrapping xbps-src"
./xbps-src binary-bootstrap

./xbps-src -t pkg dwm-wragdan
./xbps-src -t pkg st-wragdan
./xbps-src -t pkg fnm
./xbps-src -t pkg ueberzugpp 

echo "Finished xbps-src installs"
sleep 10

xi -fy dwm-wragdan st-wragdan fnm ueberzugpp 

./xbps-src clean

echo "Setting default shell for wragdan to zsh"
chsh -s /usr/bin/zsh

echo "Creating DWM log directory"
mkdir -p /home/wragdan/.logs/dwm


git clone https://github.com/Wragdan/dotfiles.git /home/wragdan/.dotfiles
cd /home/wragdan/.dotfiles

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
