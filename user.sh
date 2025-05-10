#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

green "Cloning personal void-packages"
git clone https://github.com/Wragdan/void-packages /home/wragdan/void-packages
cd /home/wragdan/void-packages
green "Checking out to branch wragdan"
git checkout wragdan

green "Bootstrapping xbps-src"
./xbps-src binary-bootstrap

green "Building and Installing 'stow' - for dotfiles symlinking"
./xbps-src pkg stow
xi -fy stow
./xbps-src clean

green "Building and Installing 'git' - from source"
./xbps-src pkg git
xi -fy git
./xbps-src clean

green "Building and Installing 'neovim' - from source"
./xbps-src pkg neovim
xi -fy neovim
./xbps-src clean

green "Building and Installing 'xorg-minimal' - from source"
./xbps-src pkg xorg-minimal
xi -fy xorg-minimal
./xbps-src clean

green "Building and Installing 'dwm' - the best window manager"
./xbps-src pkg dwm
xi -fy dwm
./xbps-src clean

green "Building and Installing 'st' - the best terminal emulator"
./xbps-src pkg st
xi -fy st
./xbps-src clean

green "Building and Installing 'zsh' - my preferred terminal"
./xbps-src pkg zsh
xi -fy zsh
./xbps-src clean

green "Building and Installing feh"
./xbps-src pkg feh
xi -fy feh
./xbps-src clean

green "Building and Installing xrandr"
./xbps-src pkg xrandr
xi -fy xrandr
./xbps-src clean

green "Building and Installing picom"
./xbps-src pkg picom
xi -fy picom
./xbps-src clean

green "Building and Installing dunst"
./xbps-src pkg dunst
xi -fy dunst
./xbps-src clean

green "Building and Installing pipewire"
./xbps-src pkg pipewire
xi -fy pipewire
./xbps-src clean

green "Building and Installing wireplumber"
./xbps-src pkg wireplumber
xi -fy wireplumber
./xbps-src clean

green "Building and Installing pipewire-pulse"
./xbps-src pkg pipewire-pulse
xi -fy pipewire-pulse
./xbps-src clean

git clone https://github.com/Wragdan/dotfiles /home/wragdan/.dotfiles
cd /home/wragdan/.dotfiles

