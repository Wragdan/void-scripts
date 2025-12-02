#!/bin/bash

set -e

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

sleep 10
echo "Finished xbps-src installs"

xi -fy dwm-wragdan st-wragdan fnm ueberzugpp 

./xbps-src clean

echo "Setting default shell for wragdan to zsh"
chsh -s /usr/bin/zsh

echo "Creating DWM log directory"
mkdir -p /home/wragdan/.logs/dwm
