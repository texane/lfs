# disk partitions sizes. first empty hole needed for grub
export LFS_DISK_EMPTY_SIZE=2
export LFS_DISK_BOOT_SIZE=128
export LFS_DISK_ROOT_SIZE=512

# filesystems
export LFS_DISK_BOOT_FS=vfat
export LFS_DISK_ROOT_FS=ext3
export LFS_SQUASH_ROOTFS=yes

# archi
export LFS_TARGET_ARCH=arm
export LFS_CROSS_COMPILE=$LFS_CROSS_COMPILE_armv7

# softwares
export LFS_LINUX_VERS=3.0.35
export LFS_LINUX_ARCH=arm
export LFS_PCIUTILS_VERS=3.1.10
export LFS_NTPD_VERS=1.0

. $LFS_TOP_DIR/board/common/do_conf.sh
