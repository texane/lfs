[ -z $LFS_LINUX_VERS ] && return

LFS_THIS_SOFT_IS_ENABLED=1
LFS_THIS_SOFT_VERS=$LFS_LINUX_VERS
LFS_THIS_SOFT_DEPS='rootfs_bone'

case $LFS_THIS_BOARD_NAME in
 rpib) LFS_THIS_SOFT_URL=https://github.com/raspberrypi/linux/archive/rpi-3.6.y.tar.gz ;;
 qseven) LFS_THIS_SOFT_URL=file:///segfs/linux/dance_sdk/tarballs/armonie_bsp/linux-$LFS_LINUX_VERS.tar.gz ;;
 bbb) LFS_THIS_SOFT_URL=file:///segfs/linux/pru_sdk/tarballs/linux-$LFS_LINUX_VERS.tar.gz ;;
 *) LFS_THIS_SOFT_URL=ftp://ftp.kernel.org/pub/linux/kernel/v3.x/linux-$LFS_LINUX_VERS.tar.bz2 ;;
esac

LFS_THIS_SOFT_BUILD_METHOD=kbuild
LFS_THIS_SOFT_KBUILD_INSTALL_PATH=$LFS_TARGET_INSTALL_DIR/boot
LFS_THIS_SOFT_KBUILD_INSTALL_MOD_PATH=$LFS_TARGET_INSTALL_DIR

LFS_THIS_SOFT_PATCHES=''
if [ $LFS_THIS_BOARD_NAME == 'comex' ]; then
 case $LFS_LINUX_VERS in
  3.6.11)
   LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.6.11_pch_gbe_main.diff"
   LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.6.11_pch_uart.diff"
   ;;
 esac
elif [ $LFS_THIS_BOARD_NAME == 'bbb' ]; then
  LFS_THIS_SOFT_KBUILD_INSTALL_TARGETS='uImage dtbs uImage-dtb.am335x-boneblack'
  LFS_THIS_SOFT_KBUILD_INSTALL_ENV_PATH=/segfs/linux/dance_sdk/toolchain/arm-buildroot-linux-uclibcgnueabi/usr/bin
  LFS_THIS_SOFT_MAKE_ARGS='LOADADDR=0x80200000'
elif [ $LFS_THIS_BOARD_NAME == 'qseven' ]; then
  LFS_THIS_SOFT_KBUILD_INSTALL_TARGETS='uImage'
  LFS_THIS_SOFT_KBUILD_INSTALL_ENV_PATH=/segfs/linux/dance_sdk/toolchain/arm-buildroot-linux-uclibcgnueabi/usr/bin
# patches from congatech already applied to tarball. see not_patched version
#  case $LFS_LINUX_VERS in
#   3.0.35)
#    LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.0.35-patches/0000-linux-3.0.35-QMX6-2013-05-08.patch"
#    LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.0.35-patches/0001-ENGR00239905-PCIe-Enable-PCIe-switch-support.patch"
#    LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.0.35-patches/0001-ENGR00240650-pcie-imx-fix-ep-device-no-int-when-pcie.patch"
#    LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.0.35-patches/0001-ENGR00241003-1-mx6-need-to-add-delay-in-LDO-voltage-.patch"
#    LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.0.35-patches/0002-ENGR00241003-2-pfuze-using-_sel-interface-to-add-del.patch"
#    LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.0.35-patches/0007-CGT000007-QMX6-Revert-ENGR00224109-MX6-FEC-optimize-ENET_REF_CLK.patch"
#    LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.0.35-patches/0008-CGT000008-QMX6-Support-for-OV5640-MIPI-camera.patch"
#    LFS_THIS_SOFT_PATCHES=" $LFS_THIS_SOFT_PATCHES $LFS_THIS_BOARD_DIR/linux-3.0.35-patches/0009-CGT000009-QMX6-Fix-incorrect-sound-playback-speed.patch"
#    ;;
#  esac
fi
