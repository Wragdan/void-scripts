#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

# Mounting root drive
BTRFS_OPTS="rw,noatime,compress=zstd,discard=async"
green "Mounting root partition to '/mnt'"
mount -o $BTRFS_OPTS /dev/mapper/cryptvoid /mnt

green "Creating SubVolumes"
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
btrfs subvolume create /mnt/@snapshots
umount /mnt

green "Mounting Subvolumes"
mount -o $BTRFS_OPTS,subvol=@ /dev/mapper/cryptvoid /mnt
mkdir /mnt/{boot,home,.snapshots}
mkdir /mnt/boot/efi
mount -o $BTRFS_OPTS,subvol=@home /dev/mapper/cryptvoid /mnt/home
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/mapper/cryptvoid /mnt/.snapshots

# Directories we do not want to snapshot
green "Creating ignored subvolumes"
mkdir -p /mnt/var/cache
btrfs su cr /mnt/var/cache/xbps
btrfs su cr /mnt/var/tmp
btrfs su cr /mnt/srv

green "Mounting EFI Partition"
mount -o rw,noatime $PART_EFI /mnt/boot/efi

