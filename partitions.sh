#!/bin/bash

echo "Enter drive to use for installation without the '/dev/'. Ex. nvme0n1, sda, sdb, etc..."
read DRIVE

FULL_DRIVE="/dev/$DRIVE"

echo "This script will delete all partitions, write 'yes' to continue"
read ANSWER

if [[ "$ANSWER" != "yes" ]]; then
    echo "You decided to cancel"
    exit 0
fi

# Deletes all partitions on $DRIVE
echo "Deleting all partitions on disk"
echo "..."
sfdisk --delete $FULL_DRIVE

# Creates 2 partitions, EFI 256M and Linux for the remaining of the disk
echo "Creating partitions"
echo "..."
echo -e 'size=256M, type=U\n size=+, type=L\n' | sfdisk $FULL_DRIVE -W always

PART_EFI=
PART_LINUX=

if [[ $FULL_DRIVE == *nvme* ]]; then
    echo "Detected NVME"
    PART_EFI="${FULL_DRIVE}p1"
    PART_LINUX="${FULL_DRIVE}p2"
fi

if [[ $FULL_DRIVE == */sd* ]]; then
    echo "Detedted HDD"
    PART_EFI="${FULL_DRIVE}1"
    PART_LINUX="${FULL_DRIVE}2"
fi

if [[ -z "$PART_EFI" ]]; then
    echo "Could not detect efi partition. aborting..."
    exit 1
fi
