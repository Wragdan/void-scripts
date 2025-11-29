The order to execute the scripts is the following:

1. partitions.sh: partitions all disks and mounts partitions
2. pre_chroot.sh: prepares the live media for installing and configuring via xchroot
  2.5. chroot.sh: useful for mounting existing partitions to reconfigure something using xchroot
3. system.sh: configures and installs void linux onto the mounted chroot disk
4. env.sh: once you rebooted into your installation run this to configure some environments
5. services.sh: enables services required to continue configuring the user
6. packages.sh: installs all packages from our void-packages repository
7. dotfiles.sh: adds dotfiles and configures all inside .config
