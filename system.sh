#!/bin/bash

SCRIPT_DIR=$(dirname "$0")

source "$SCRIPT_DIR/env.bash"

chown root:root /
chmod 755 /

echo "Setting timezone to America/Tegucigalpa"
ln -sf /usr/share/zoneinfo/America/Tegucigalpa /etc/localtime

echo "Setting locale to en_US.UTF-8"
cp /etc/default/libc-locales /etc/default/libc-locales.backup
sed -i 's/^\#en_US.UTF-8/en_US.UTF-8/' /etc/default/libc-locales
xbps-reconfigure -f glibc-locales

echo "Changing root password"
passwd root

echo "What would the hostname be?"
read HOST_NAME

echo "$HOST_NAME" > /etc/hostname

cat <<EOF > /etc/hosts
#
# /etc/hosts: static lookup table for host names
#
127.0.0.1        localhost
::1              localhost
127.0.1.1        ${HOST_NAME}.localdomain ${HOST_NAME}
EOF

echo "Creating user 'wragdan'"
useradd wragdan
echo "Changing password for 'wragdan'"
passwd wragdan
echo "Changing groups for 'wragdan'"
usermod -aG wheel,input,audio,video,scanner,network,storage,xbuilder wragdan

echo "Configuring sudoers"
echo "%wheel ALL=(ALL:ALL) ALL" >/etc/sudoers.d/00-wheel-can-sudo
echo "%wheel ALL=(ALL:ALL) NOPASSWD: /usr/bin/shutdown,/usr/bin/reboot,/usr/bin/poweroff,/usr/bin/mount,/usr/bin/umount,/usr/bin/xbps-install -Syu,/usr/bin/xbps-install -Syyu,/usr/bin/xbps-install -Syyu --noconfirm" > /etc/sudoers.d/01-cmds-without-password
echo "Defaults editor=/usr/bin/nvim" >/etc/sudoers.d/02-visudo-editor

echo "Change default shell to bash for root"
chsh -s /bin/bash root

echo "Add nonfree and multilib repositories"
xbps-install -Syu void-repo-nonfree void-repo-multilib

EFI_UUID=$(blkid -s UUID -o value "$PART_EFI")
ROOT_UUID=$(blkid -s UUID -o value /dev/mapper/cryptvoid)
LUKS_UUID=$(blkid -s UUID -o value "$PART_LINUX")

echo "Generating fstab"
cat <<EOF > /etc/fstab
# <file system>                           <dir>         <type>    <options>                             <dump> <pass>
UUID=$ROOT_UUID /             btrfs     $BTRFS_OPTS,subvol=@            0 1
UUID=$ROOT_UUID /home         btrfs     $BTRFS_OPTS,subvol=@home        0 2
UUID=$ROOT_UUID /.snapshots   btrfs     $BTRFS_OPTS,subvol=@snapshots   0 2
UUID=$EFI_UUID                            /boot/efi     vfat      defaults,noatime                      0 2
tmpfs                                     /tmp          tmpfs     defaults,nosuid,nodev                 0 0
EOF

if ! grep -q "GRUB_ENABLE_CRYPTODISK=y" /etc/default/grub; then
  echo "Adding line 'GRUB_ENABLE_CRYPTODISK=y' to /etc/default/grub"  
  echo GRUB_ENABLE_CRYPTODISK=y >> /etc/default/grub
fi

#GRUB_CMDLINE_LINUX_DEFAULT="cryptdevice=UUID=<your_luks_uuid>:cryptroot root=/dev/mapper/cryptroot rootflags=subvol=@ loglevel=3 quiet"

echo "Backing up /etc/default/grub"
cp /etc/default/grub /etc/default/grub.backup

#OLDLINE='GRUB_CMDLINE_LINUX_DEFAULT*'
#NEWLINE='GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.auto=1 rd.luks.allow-discards"'

echo "Changing GRUB_CMDLINE_LINUX_DEFAULT"
sed -i 's/^GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4"/GRUB_CMDLINE_LINUX_DEFAULT="loglevel=4 rd.auto=1 rd.luks.allow-discards"/' /etc/default/grub
echo "Check results"
cat /etc/default/grub | grep GRUB_CMDLINE_LINUX_DEFAULT

echo "Configuring luks key"
dd bs=1 count=64 if=/dev/urandom of=/boot/volume.key
echo "Please anter your crypt passphrase"
cryptsetup luksAddKey "$PART_LINUX" /boot/volume.key
chmod 000 /boot/volume.key
chmod -R g-rwx,o-rwx /boot

echo "Adding key to /etc/crypttab"
cat <<EOF >> /etc/crypttab
cryptvoid UUID=$LUKS_UUID /boot/volume.key luks
EOF

echo "Creating file /etc/dracut.conf.d/10-crypt.conf"
cat <<EOF >> /etc/dracut.conf.d/10-crypt.conf
install_items+=" /boot/volume.key /etc/crypttab "
EOF

echo "Do you need --removable flag for grub? Type 'yes' if you need grub to be removable"
read ANSWER

if [[ "$ANSWER" == "yes" ]]; then
    echo "Installing bootloader with --removable"
    grub-install "$FULL_DRIVE" --removable
else
    echo "Installing bootloader"
    grub-install "$FULL_DRIVE"
fi

echo "Installing necessary packages to continue installation on reboot"
xbps-install -Syu git xtools

echo "Ensure an initramfs is generated"
xbps-reconfigure -fa

echo "Copying void-scripts to user 'wragdan'"
cp -r /tmp/void-scripts /home/wragdan/void-scripts
chown -R wragdan:wragdan /home/wragdan/void-scripts

echo "Configuring yubikey support"
mkdir -p /etc/udev/rules.d
cat <<EOF > /etc/udev/rules.d/90-yubikey.rules
ACTION=="add|change",SUBSYSTEM=="usb|hidraw", ATTRS={idvendor}=="1050", GROUP="wheel", MODE=0660
EOF

echo "nouveau blacklist"
cat <<EOF > /etc/modprobe.d/nouveau_blacklist.conf
blacklist nouveau
EOF

echo "Installing librewolf"
cat <<EOF > /etc/xbps.d/20-librewolf.conf
repository=https://github.com/index-0/librewolf-void/releases/latest/download/
EOF
xbps-install -Syu librewolf

echo "Installing ungoogled-chromium"
cat <<EOF > /etc/xbps.d/20-ungoogled-chromium.conf
repository=https://github.com/DAINRA/ungoogled-chromium-void/releases/latest/download/
EOF
xbps-install -Syu ungoogled-chromium

echo "Configuring dumb_runtime_dir"
sed -i '/pam_dumb_runtime_dir.so/d' /etc/pam.d/system-login
cat <<EOF > /etc/pam.d/system-login
#%PAM-1.0

auth       required   pam_shells.so
auth       requisite  pam_nologin.so
auth       include    system-auth

account    required   pam_access.so
account    required   pam_nologin.so
account    include    system-auth

password   include    system-auth

session    optional   pam_loginuid.so
session    include    system-auth
session    optional   pam_motd.so          motd=/etc/motd
session    optional   pam_mail.so          dir=/var/mail standard quiet
-session   optional   pam_turnstile.so
-session   optional   pam_elogind.so
session    optional   pam_dumb_runtime_dir.so
session    required   pam_env.so
EOF

sudo xbps-install -Syu NetworkManager delta gcc sof-firmware alsa-utils eww stow git neovim xorg dmenu zsh feh xrandr picom dunst pulsemixer pipewire wireplumber sxhkd zoxide dbus starship yazi zathura eza fzf zsh-syntax-highlighting zsh-autosuggestions rustup luarocks ripgrep gnupg xclip cifs-utils dumb_runtime_dir chrony mpd ncmpcpp noto-fonts-cjk noto-fonts-emoji

#ln -s /etc/sv/wpa_supplicant /etc/runit/runsvdir/default/ 
#ln -s /etc/sv/dhcpcd-eth0 /etc/runit/runsvdir/default/ 
#ln -s /etc/sv/dhcpcd /etc/runit/runsvdir/default/
ln -s /etc/sv/NetworkManager /etc/runit/runsvdir/default/
ln -s /etc/sv/chronyd /etc/runit/runsvdir/default/
ln -s /etc/sv/dbus /etc/runit/runsvdir/default/
exit 0
