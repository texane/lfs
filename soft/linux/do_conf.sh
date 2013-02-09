[ -z $LFS_LINUX_VERS ] && return

LFS_THIS_SOFT_IS_ENABLED=1
LFS_THIS_SOFT_VERS=$LFS_LINUX_VERS
LFS_THIS_SOFT_DEPS='rootfs_bone'

case $LFS_THIS_BOARD_NAME in
 rpib) LFS_THIS_SOFT_URL=https://github.com/raspberrypi/linux/archive/rpi-3.6.y.tar.gz ;;
 comex) LFS_THIS_SOFT_URL=ftp://ftp.kernel.org/pub/linux/kernel/v3.x/linux-$LFS_LINUX_VERS.tar.bz2 ;;
esac

LFS_THIS_SOFT_BUILD_METHOD=kbuild
LFS_THIS_SOFT_KBUILD_INSTALL_PATH=$LFS_TARGET_INSTALL_DIR/boot
LFS_THIS_SOFT_KBUILD_INSTALL_MOD_PATH=$LFS_TARGET_INSTALL_DIR
