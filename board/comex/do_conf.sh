# disk partitions sizes. first empty hole needed for grub
export LFS_DISK_EMPTY_SIZE=2
export LFS_DISK_BOOT_SIZE=128
export LFS_DISK_ROOT_SIZE=256

# archi
export LFS_TARGET_ARCH=x86
export LFS_CROSS_COMPILE=$LFS_CROSS_COMPILE_x86

# softwares
export LFS_LINUX_VERS=3.6.11
export LFS_LINUX_ARCH=x86
export LFS_PCIUTILS_VERS=3.1.10
export LFS_GRUB_VERS=2.00
export LFS_DANCE_VERS=any

. $LFS_TOP_DIR/board/common/do_conf.sh
