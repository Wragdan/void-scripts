#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

source "$SCRIPT_DIR/env.bash"

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
xbps-install -Sy

green "Add nonfree and multilib repositories"
xbps-install -y void-repo-nonfree
xbps-install -Sy
xbps-install -y void-repo-multilib
xbps-install -Sy

EFI_UUID=$(blkid -s UUID -o value $PART_EFI)
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/cryptvoid)
LUKS_UUID=$(blkid -s UUID -o value $PART_LINUX)

green "Generating fstab"
cat <<EOF > /etc/fstab
# <file system>   <dir>         <type>    <options>                     <dump> <pass>
UUID=$ROOT_UUID   /             btrfs     $BTRFS_OPTS,subvol=@          0 1
UUID=$ROOT_UUID   /home         btrfs     $BTRFS_OPTS,subvol=@home      0 2
UUID=$ROOT_UUID   /.snapshots   btrfs     $BTRFS_OPTS,subvol=@snapshots 0 2
UUID=$EFI_UUID    /boot/efi     vfat      defaults,noatime              0 2
tmpfs             /tmp          tmpfs     defaults,nosuid,nodev         0 0
EOF

if ! grep -q "GRUB_ENABLE_CRYPTODISK=y" /etc/default/grub; then
  green "Adding line 'GRUB_ENABLE_CRYPTODISK=y' to /etc/default/grub"  
  echo GRUB_ENABLE_CRYPTODISK=y >> /etc/default/grub
fi

#GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID=<your_luks_uuid>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ loglevel=3 quiet"

green "Backing up /etc/default/grub"
cp /etc/default/grub /etc/default/grub.backup

#OLDLINE='GRUB_CMDLINE_LINUX_DEFAULT*'
#NEWLINE='GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.auto=1 rd.luks.allow-discards"'

green "Changing GRUB_CMDLINE_LINUX_DEFAULT"
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT*/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.auto=1 rd.luks.allow-discards"/' /etc/default/grub
green "Check results"
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT

green "Configuring luks key"
dd bs=1 count=64 if=/dev/urandom of=/boot/volume.key
cryptsetup luksAddKey $PART_LINUX /boot/volume.key
chmod 000 /boot/volume.key
chmod -R g-rwx,o-rwx /boot

green "Adding key to /etc/crypttab"
cat <<EOF >> /etc/crypttab
cryptvoid UUID=$LUKS_UUID /boot/volume.key luks
EOF

green "Creating file /etc/dracut.conf.d/10-crypt.conf"
cat <<EOF >> /etc/dracut.conf.d/10-crypt.conf
install_items+=" /boot/volume.key /etc/crypttab "
EOF

green "Installing bootloader onto disk"
grub-install $FULL_DRIVE
