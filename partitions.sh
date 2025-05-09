#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

# Check if crypt is already open. Useful for development of the script
CRYPT_OPEN=$(cryptsetup status cryptvoid)

if [[ $CRYPT_OPEN != *inactive* ]]; then
    red "Unmounting in case disks are mounted"
    umount /mnt/.snapshots
    umount /mnt/home
    umount /mnt/boot/efi
    umount /mnt
    red "Crypt is open, closing..."
    cryptsetup close cryptvoid
fi

echo "Enter drive to use for installation without the '/dev/'. Ex. nvme0n1, sda, sdb, etc..."
read DRIVE

FULL_DRIVE="/dev/$DRIVE"

red "WARNING!!! This script will delete all partitions, write 'yes' to continue"
read ANSWER

if [[ "$ANSWER" != "yes" ]]; then
    bold_red "You decided to cancel"
    exit 0
fi

# Deletes all partitions on $DRIVE
green "Deleting all partitions on disk"
sfdisk --delete $FULL_DRIVE

# Creates 2 partitions, EFI 256M and Linux for the remaining of the disk
green "Creating partitions"
echo -e 'size=256M, type=U\n size=+, type=L\n' | sfdisk $FULL_DRIVE -W always

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

if [[ -z "$PART_EFI" ]]; then
    bold_red "Could not detect efi partition. aborting..."
    exit 1
fi


green "Encrypting Linux partition"
cryptsetup luksFormat --type luks1 -y $PART_LINUX
green "Opening encrypted partition"
cryptsetup luksOpen $PART_LINUX cryptvoid

green "Formatting partitions"
green "Formatting EFI partition"
mkfs.fat -F32 -n EFI $PART_EFI
green "Formatting root partition"
mkfs.btrfs -L Void /dev/mapper/cryptvoid
