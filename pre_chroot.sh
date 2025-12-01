#!/bin/bash

source env.bash


(
    echo "Copying xbps keys"
    mkdir -p /mnt/var/db/xbps/keys
    cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

    echo "Installing base system and required packages"
    xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt base-system cryptsetup grub-x86_64-efi btrfs-progs

    echo "Copying void scripts to /mnt"
    cp -r ../void-scripts /mnt/tmp/void-scripts

) 2>&1 | dialog --title "$TITLE" --progressbox 30 120


dialog --backtitle "$BACKTITLE" \
       --title "Chroot prepared" \
       --msgbox "After chroot starts, run /tmp/void-scripts/system.sh" 8 50

xchroot /mnt
