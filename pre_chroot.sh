#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

green "Copying xbps keys"
mkdir -p /mnt/var/db/xbps/keys
cp /var/db/xbps/keys/* /mnt/var/db/xbps/keys/

green "Installing base system and required packages"
xbps-install -Sy -R https://repo-default.voidlinux.org/current -r /mnt base-system cryptsetup grub-x86_64-efi btrfs-progs vim

#green "Generating fstab"
# Not using xgenfstab since it maps using the mounting point instead of the disk uuid
#xgenfstab /mnt > /mnt/etc/fstab

green "starting"

#green "Mounting virtual filesystem"
#for dir in dev proc sys run; do mount --rbind /$dir /mnt/$dir; mount --make-rslave /mnt/$dir; done
#green "Copying resolve.conf"
#cp /etc/resolve.conf /mnt/etc/
#green "Starting chroot"
#BTRFS_OPTS=$BTRFS_OPTS PS1='(chroot) # ' chroot /mnt/ /bin/bash

# prefer xchroot
green "Starting chroot"
BTRFS_OPTS=$BTRFS_OPTS xchroot /mnt
