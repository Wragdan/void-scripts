The order to execute the scripts is the following:

1. partitions.sh: partitions all disks and mounts partitions
  1.5. chroot.sh: useful for mounting existing partitions to reconfigure something using xchroot
2. system.sh: configures and installs void linux onto the mounted chroot disk
3. packages.sh: installs all packages from our void-packages repository
4. dotfiles.sh: adds dotfiles and configures all inside .config
