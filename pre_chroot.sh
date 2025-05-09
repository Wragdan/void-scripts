#!/bin/bash

green "Copying xbps keys"
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

green "Installing base system and required packages"
xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt base-system cryptsetup grub-x86_64-efi btrfs-progs vim

xgenfstab /mnt > /mnt/etc/fstab
