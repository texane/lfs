# disk partitions sizes. first empty hole needed for grub
export LFS_DISK_EMPTY_SIZE=2
export LFS_DISK_BOOT_SIZE=128
export LFS_DISK_ROOT_SIZE=256

# filesystems
export LFS_DISK_ROOT_FS=ext3

# archi
export LFS_TARGET_ARCH=x86_64
export LFS_CROSS_COMPILE=$LFS_CROSS_COMPILE_x86_64

# softwares
export LFS_LINUX_VERS=3.6.11
export LFS_LINUX_ARCH=x86_64
export LFS_PCIUTILS_VERS=3.1.10
export LFS_GRUB_VERS=2.00
export LFS_NTPD_VERS=1.0

. $LFS_TOP_DIR/board/common/do_conf.sh
