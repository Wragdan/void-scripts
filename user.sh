#!/bin/bash

set -e

# sudo -u wragdan

# echo "Cloning personal void-packages"
# if [ ! -d "/home/wragdan/void-packages" ] ; then
#     git clone https://github.com/Wragdan/void-packages /home/wragdan/void-packages
# fi
# cd /home/wragdan/void-packages
# git checkout wragdan

# echo "Starting xbps-src installs"
# sleep 10

# echo "Bootstrapping xbps-src"
# ./xbps-src binary-bootstrap

# ./xbps-src -t pkg dwm-wragdan
# ./xbps-src -t pkg st-wragdan
# ./xbps-src -t pkg fnm
# ./xbps-src -t pkg ueberzugpp 

# echo "Finished xbps-src installs"
# sleep 10

# xi -fy dwm-wragdan st-wragdan fnm ueberzugpp 

#./xbps-src clean

echo "Setting default shell for wragdan to zsh"
chsh -s /usr/bin/zsh wragdan

echo "Creating DWM log directory"
# mkdir -p /home/wragdan/.logs/dwm
mkdir -p /home/wragdan/.cache/zsh
chown -R wragdan:wragdan /home/wragdan/.cache/zsh


git clone https://github.com/Wragdan/dotfiles.git /home/wragdan/.dotfiles
chown -R wragdan:wragdan /home/wragdan/.dotfiles
cd /home/wragdan/.dotfiles

# stow x11
sudo -u wragdan stow shell
sudo -u wragdan stow zsh
sudo -u wragdan stow zathura
sudo -u wragdan stow yazi
sudo -u wragdan stow sxhkd
sudo -u wragdan stow starship
sudo -u wragdan stow pulse
sudo -u wragdan stow pipewire
sudo -u wragdan stow picom
sudo -u wragdan stow nvim
sudo -u wragdan stow local
sudo -u wragdan stow mpd
sudo -u wragdan stow ncmpcpp
sudo -u wragdan stow fontconfig
# sudo -u wragdan stow eww
sudo -u wragdan stow git

sudo -u wragdan touch /home/wragdan/.config/shell/secrets

#echo "Configuring rust - Please select default installation"
#rustup-init

# echo "Installing node version 22"
# fnm install 22
