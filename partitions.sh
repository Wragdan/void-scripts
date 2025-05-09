#!/bin/bash

echo "Enter drive to use for installation"
read DRIVE

echo "This script will delete all partitions, write 'yes' to continue"
read DELETE_PARTITIONS

if [[ "$DELETE_PARTITIONS" != "yes" ]]; then
    echo "You decided to cancel"
    exit 0
fi

# Deletes all partitions on $DRIVE
echo "Deleting all partitions on disk"
echo "..."
sfdisk --delete $DRIVE

# Creates 2 partitions, EFI 256M and Linux for the remaining of the disk
echo "Creating partitions"
echo "..."
echo -e 'size=256M, type=U\n size=+, type=L\n' | sfdisk $DRIVE
