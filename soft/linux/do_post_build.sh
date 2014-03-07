[ -z $LFS_LINUX_VERS ] && return

case $LFS_THIS_BOARD_NAME in
 bbb)
 # install zImage
 rm -f $LFS_TARGET_INSTALL_DIR/boot/uImage 2> /dev/null
 cp -f $LFS_THIS_SOFT_SRC/arch/arm/boot/zImage $LFS_TARGET_INSTALL_DIR/boot/zImage
 # install dtbs
 mkdir -p $LFS_TARGET_INSTALL_DIR/boot/dtbs 2> /dev/null
 cp -f $LFS_THIS_SOFT_SRC/arch/arm/boot/dts/am335x-boneblack.dtb \
 $LFS_TARGET_INSTALL_DIR/boot/dtbs/am335x-boneblack.dtb
 # install firmwares
 mkdir -p $LFS_TARGET_INSTALL_DIR/lib/firmware 2> /dev/null
 cp -f $LFS_THIS_SOFT_SRC/firmware/*.dtbo $LFS_TARGET_INSTALL_DIR/lib/firmware/
 cp -f $LFS_THIS_SOFT_SRC/firmware/*.bin $LFS_TARGET_INSTALL_DIR/lib/firmware/
 ;;
 *) ;;
esac
