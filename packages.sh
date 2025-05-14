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

# TODO: install only necessary packages
green "Building and Installing 'xorg' - from source"
./xbps-src pkg xorg
xi -fy xorg
./xbps-src clean

green "Building and Installing 'dwm' - the best window manager"
./xbps-src pkg dwm
xi -fy dwm
./xbps-src clean

green "Building and Installing 'st' - the best terminal emulator"
./xbps-src pkg st
xi -fy st
./xbps-src clean

green "Building and Installing dmenu"
./xbps-src pkg dmenu
xi -fy dmenu
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

green "Building and Installing sxhkd"
./xbps-src pkg sxhkd 
xi -fy sxhkd 
./xbps-src clean

green "Building and Installing zoxide"
./xbps-src pkg zoxide 
xi -fy zoxide 
./xbps-src clean

green "Building and Installing dbus"
./xbps-src pkg dbus 
xi -fy dbus 
./xbps-src clean

green "Building and Installing starship"
./xbps-src pkg starship 
xi -fy starship 
./xbps-src clean

green "Building and Installing yazi"
./xbps-src pkg yazi 
xi -fy yazi 
./xbps-src clean

green "Building and Installing zathura"
./xbps-src pkg zathura 
xi -fy zathura 
./xbps-src clean

green "Building and Installing eza"
./xbps-src pkg eza 
xi -fy eza 
./xbps-src clean

green "Installing nvidia drivers"
./xbps-src pkg nvidia 
xi -fy nvidia 
./xbps-src clean

green "Installing fzf"
./xbps-src pkg fzf 
xi -fy fzf 
./xbps-src clean

#green "Installing fnm"
#./xbps-src pkg fnm 
#xi -fy fnm 
#./xbps-src clean

green "Installing qutebrowser"
./xbps-src pkg qutebrowser 
xi -fy qutebrowser 
./xbps-src clean

green "Setting default shell for wragdan to zsh"
chsh -s /usr/bin/zsh

green "Creating DWM log directory"
mkdir -p /home/wragdan/.logs/dwm

cat <<EOF > /etc/modprobe.d/nouveau_blacklist.conf
blacklist nouveau
EOF
