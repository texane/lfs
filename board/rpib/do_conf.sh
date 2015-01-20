# disk partition sizes
export LFS_DISK_EMPTY_SIZE=0
export LFS_DISK_BOOT_SIZE=128
export LFS_DISK_ROOT_SIZE=256
export LFS_DISK_APP_SIZE=256

# filesystems
export LFS_DISK_ROOT_FS=ext2
export LFS_DISK_APP_FS=ext2

# archi
export LFS_TARGET_ARCH=arm
export LFS_CROSS_COMPILE=$LFS_CROSS_COMPILE_armv6

# softwares
export LFS_LINUX_VERS=3.6.11
export LFS_LINUX_ARCH=arm

. $LFS_TOP_DIR/board/common/do_conf.sh
