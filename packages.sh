#!/bin/bash

set -e

echo "Cloning personal void-packages"
if [ ! -d "/home/wragdan/void-packages" ] ; then
    git clone https://github.com/Wragdan/void-packages /home/wragdan/void-packages
fi
cd /home/wragdan/void-packages

echo "Checking out to branch wragdan"
git checkout wragdan

echo "Bootstrapping xbps-src"
./xbps-src binary-bootstrap

echo "Building and Installing 'dwm' - the best window manager"
./xbps-src pkg dwm-wragdan
xi -fy dwm-wragdan

echo "Building and Installing 'st' - the best terminal emulator"
./xbps-src pkg st-wragdan
xi -fy st-wragdan

echo "Installing fnm"
./xbps-src pkg fnm
xi -fy fnm

echo "Building and Installing ueberzugpp"
./xbps-src pkg ueberzugpp 
xi -fy ueberzugpp 

./xbps-src clean

echo "Setting default shell for wragdan to zsh"
chsh -s /usr/bin/zsh

echo "Creating DWM log directory"
mkdir -p /home/wragdan/.logs/dwm
