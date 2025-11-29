#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

green "Enabling necessary services"
ln -s /etc/sv/wpa_supplicant /var/service
ln -s /etc/sv/dhcpcd-eth0 /var/service
ln -s /etc/sv/dhcpcd /var/service
ln -s /etc/sv/chronyd /var/service
ln -s /etc/sv/dbus /var/service
