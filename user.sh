#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

green "Cloning personal void-packages"
git clone https://github.com/Wragdan/void-packages
cd void-packages
green "Checking out to branch wragdan"
git checkout wragdan

green "Bootstrapping xbps-src"
./xbps-src binary-bootstrap

green "Building and Installing 'stow' - for dotfiles symlinking"
./xbps-src pkg stow
xi -f stow
./xbps-src clean

green "Building and Installing 'git' - from source"
./xbps-src pkg git
xi -f git
./xbps-src clean

green "Building and Installing 'neovim' - from source"
./xbps-src pkg neovim
xi -f neovim
./xbps-src clean
