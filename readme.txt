The order to execute the scripts is the following:

1. partitions.sh: partitions all disks and mounts partitions
  1.5. chroot.sh: useful for mounting existing partitions to reconfigure something using xchroot
2. system.sh: configures and installs void linux onto the mounted chroot disk
3. user.sh: completes installation for user files, packages and dotfiles
