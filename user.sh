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
