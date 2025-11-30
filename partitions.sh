#!/bin/bash

set -e

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

TITLE="Void Linux Installer"
BACKTITLE="Partition Disks"

if ! command -v dialog &> /dev/null; then
    echo "Error: 'dialog' command not found. Please install it (e.g., 'sudo xbps-install dialog' on Void)."
    exit 1
fi

dialog --backtitle "$BACKTITLE" \
       --title "$TITLE" \
       --msgbox "Starting cleanup. Deleting 'env.bash' file." 6 50

echo "Deleting env file"
rm -rf env.bash

#dialog --msgbox "Unmounting partitions in case they are mounted" 1920 1080
dialog --backtitle "$BACKTITLE" \
       --title "$TITLE" \
       --msgbox "Unmounting file systems..." 6 50
echo "Unmounting partitions..."
umount /mnt/.snapshots 2>/dev/null
umount /mnt/home 2>/dev/null
umount /mnt/boot/efi 2>/dev/null
umount /mnt 2>/dev/null
#umount /mnt/.snapshots
#umount /mnt/home
#umount /mnt/boot/efi
#umount /mnt

CRYPT_DEVICE="cryptvoid"
CRYPT_STATUS=$(cryptsetup status "$CRYPT_DEVICE" 2>&1)

if [[ $CRYPT_STATUS != *inactive* ]]; then
    
    # Dialog to confirm closing the open crypt device
    dialog --backtitle "$BACKTITLE" \
           --title "Encryption Check" \
           --yesno "The encrypted device '$CRYPT_DEVICE' is currently open. Do you want to close it?" 8 60
    
    # Capture the exit status of the dialog (0 for Yes, 1 for No/Cancel)
    response=$?

    if [ $response -eq 0 ]; then
        dialog --backtitle "$BACKTITLE" \
               --title "Action" \
               --msgbox "Closing crypt device: $CRYPT_DEVICE" 6 50
        echo "Crypt is open, closing..."
        cryptsetup close "$CRYPT_DEVICE"
    else
        dialog --backtitle "$BACKTITLE" \
               --title "Action" \
               --msgbox "Crypt device was left open. This may cause issues later." 8 50
    fi
fi

## Check if crypt is already open. Useful for development of the script
#CRYPT_OPEN=$(cryptsetup status cryptvoid)
#if [[ $CRYPT_OPEN != *inactive* ]]; then
#    red "Crypt is open, closing..."
#    cryptsetup close cryptvoid
#fi

DRIVE=""
while true; do
    # Dialog to ask for the drive name
    DRIVE_INPUT=$(dialog --backtitle "$BACKTITLE" \
                         --title "Drive Selection" \
                         --inputbox "Enter the target drive (e.g., nvme0n1, sda, sdb) without '/dev/'." 10 60 3>&1 1>&2 2>&3)
    
    # Check if the user pressed Cancel or provided empty input
    if [ $? -ne 0 ] || [ -z "$DRIVE_INPUT" ]; then
        dialog --backtitle "$BACKTITLE" \
               --title "ERROR" \
               --yesno "Input is required. Do you want to quit the installer?" 8 50
        if [ $? -eq 0 ]; then
            exit 1
        fi
        continue
    fi

    # Set the DRIVE variable and break the loop
    DRIVE="$DRIVE_INPUT"
    break
done

# 5. Final Confirmation (Optional but recommended)
dialog --backtitle "$BACKTITLE" \
       --title "Confirmation" \
       --msgbox "Installation will proceed on drive: /dev/$DRIVE. Press OK to continue." 8 60

echo "Using drive: /dev/$DRIVE"

#echo "Enter drive to use for installation without the '/dev/'. Ex. nvme0n1, sda, sdb, etc..."
#read DRIVE

#FULL_DRIVE="/dev/$DRIVE"
#echo "export FULL_DRIVE=$FULL_DRIVE" >> env.bash
#
#red "WARNING!!! This script will delete all partitions, write 'yes' to continue"
#read ANSWER
#
#if [[ "$ANSWER" != "yes" ]]; then
#    bold_red "You decided to cancel"
#    exit 0
#fi
#
## Deletes all partitions on $DRIVE
#green "Deleting all partitions on disk"
#sfdisk --delete $FULL_DRIVE -W always
#
## Creates 2 partitions, EFI 256M and Linux for the remaining of the disk
#green "Creating partitions"
#echo -e 'size=256M, type=U\n size=+, type=L\n' | sfdisk $FULL_DRIVE -W always
#
#PART_EFI=
#PART_LINUX=
#
#if [[ $FULL_DRIVE == *nvme* ]]; then
#    green "Detected NVME"
#    PART_EFI="${FULL_DRIVE}p1"
#    PART_LINUX="${FULL_DRIVE}p2"
#fi
#
#if [[ $FULL_DRIVE == */sd* ]]; then
#    green "Detedted HDD"
#    PART_EFI="${FULL_DRIVE}1"
#    PART_LINUX="${FULL_DRIVE}2"
#fi
#
#if [[ -z "$PART_EFI" ]]; then
#    bold_red "Could not detect efi partition. aborting..."
#    exit 1
#fi
#
#echo "export PART_EFI=$PART_EFI" >> env.bash
#echo "export PART_LINUX=$PART_LINUX" >> env.bash
#
#green "Encrypting Linux partition"
#cryptsetup luksFormat --type luks1 -y $PART_LINUX
#green "Opening encrypted partition"
#cryptsetup luksOpen $PART_LINUX cryptvoid
#
#green "Formatting partitions"
#green "Formatting EFI partition"
#mkfs.fat -F32 -n EFI $PART_EFI
#green "Formatting root partition"
#mkfs.btrfs -L Void /dev/mapper/cryptvoid
#
## Mounting root drive
#BTRFS_OPTS="rw,noatime,compress=zstd,discard=async"
#echo "export BTRFS_OPTS=$BTRFS_OPTS" >> env.bash
#
#green "Mounting root partition to '/mnt'"
#mount -o $BTRFS_OPTS /dev/mapper/cryptvoid /mnt
#
#green "Creating SubVolumes"
#btrfs subvolume create /mnt/@
#btrfs subvolume create /mnt/@home
#btrfs subvolume create /mnt/@snapshots
#umount /mnt
#
#green "Mounting Subvolumes"
#mount -o $BTRFS_OPTS,subvol=@ /dev/mapper/cryptvoid /mnt
#mkdir /mnt/{boot,home,.snapshots}
#mkdir /mnt/boot/efi
#mount -o $BTRFS_OPTS,subvol=@home /dev/mapper/cryptvoid /mnt/home
#mount -o $BTRFS_OPTS,subvol=@snapshots /dev/mapper/cryptvoid /mnt/.snapshots
#
## Directories we do not want to snapshot
#green "Creating ignored subvolumes"
#mkdir -p /mnt/var/cache
#btrfs su cr /mnt/var/cache/xbps
#btrfs su cr /mnt/var/tmp
#btrfs su cr /mnt/srv
#
#green "Mounting EFI Partition"
#mount -o rw,noatime $PART_EFI /mnt/boot/efi
#
#green "All disks configured correctly."
#green "Run ./pre_chroot.sh to continue the installation process"

