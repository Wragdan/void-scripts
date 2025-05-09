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
sfdisk --delete $DRIVE
