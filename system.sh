#!/bin/bash

red() { echo -e "\033[31m$*\033[0m"; }
green() { echo -e "\033[32m$*\033[0m"; }
bold_red() { echo -e "\033[1;31m$*\033[0m"; }

chown root:root /
chmod 755 /

green "Changing root password"
passwd root

green "What would the hostname be?"
read HOST_NAME

echo $HOST_NAME > /etc/hostname

green "Creating user 'wragdan'"
useradd wragdan
green "Changing password for 'wragdan'"
passwd wragdan
green "Changing groups for 'wragdan'"
usermod -aG wheel,input,audio,video wragdan

green "Change default shell to bash for root"
chsh -s /bin/bash root

green "Sync repositories"
xbps-install -S

green "Add nonfree and multilib repositories"
xbps-install void-repo-nonfree
xbps-install -S
xbps-install void-repo-multilib
xbps-install -S

EFI_UUID=$(blkid -s UUID -o value $PART_EFI)
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/cryptvoid)
LUKS_UUID=$(blkid -s UUID -o value $PART_LINUX)
