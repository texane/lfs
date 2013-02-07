case $LFS_THIS_BOARD_NAME in
 rpib) LFS_RETURN_VALUE=https://github.com/raspberrypi/linux/archive/rpi-$LFS_LINUX_VERS.tar.gz ;;
 comex) LFS_RETURN_VALUE=ftp://ftp.kernel.org/pub/linux/kernel/v3.x/linux-$LFS_LINUX_VERS.tar.bz2 ;;
esac
