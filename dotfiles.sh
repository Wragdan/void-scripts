#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

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

touch /home/wragdan/.config/shell/secrets

green "Configuring rust - Please select default installation"
rustup-init

green "Installing node version 22"
fnm install 22

mkdir -p /etc/udev/rules.d

cat <<EOF > /etc/udev/rules.d/90-yubikey.rules
ACTION=="add|change",SUBSYSTEM=="usb|hidraw", ATTRS={idvendor}=="1050", GROUP="wheel", MODE=0660
EOF
