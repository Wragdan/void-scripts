#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

green "Preparing everything for chroot"

echo "Enter drive where void linux is installed"
read DRIVE

FULL_DRIVE="/dev/$DRIVE"

PART_EFI=
PART_LINUX=

if [[ $FULL_DRIVE == *nvme* ]]; then
    green "Detected NVME"
    PART_EFI="${FULL_DRIVE}p1"
    PART_LINUX="${FULL_DRIVE}p2"
fi

if [[ $FULL_DRIVE == */sd* ]]; then
    green "Detedted HDD"
    PART_EFI="${FULL_DRIVE}1"
    PART_LINUX="${FULL_DRIVE}2"
fi

green "Opening encrypted partition"
cryptsetup luksOpen $PART_LINUX cryptvoid

BTRFS_OPTS="rw,noatime,compress=zstd,discard=async"

green "Mounting root partition to '/mnt'"
mount -o $BTRFS_OPTS /dev/mapper/cryptvoid /mnt

green "Mounting Subvolumes"
mount -o $BTRFS_OPTS,subvol=@ /dev/mapper/cryptvoid /mnt
mount -o $BTRFS_OPTS,subvol=@home /dev/mapper/cryptvoid /mnt/home
mount -o $BTRFS_OPTS,subvol=@snapshots /dev/mapper/cryptvoid /mnt/.snapshots
mount -o rw,noatime $PART_EFI /mnt/boot/efi

green "Copying void scripts to /mnt"
cp -r ../void-scripts /mnt/tmp/void-scripts

green "All configure correctly, entering chroot"
xchroot /mnt
