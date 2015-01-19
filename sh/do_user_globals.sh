# toolchains
export LFS_CROSS_COMPILE_x86=$LFS_HOST_INSTALL_DIR/i686-nptl-linux-gnu/bin/i686-nptl-linux-gnu-
export LFS_CROSS_COMPILE_x86_64=/usr/bin/
export LFS_CROSS_COMPILE_armv6=$LFS_HOST_INSTALL_DIR/armv6-rpi-linux-gnueabi/bin/armv6-rpi-linux-gnueabi-
export LFS_CROSS_COMPILE_armv7=$LFS_HOST_INSTALL_DIR/armv6-rpi-linux-gnueabi/bin/armv6-rpi-linux-gnueabi-

case "$HOSTNAME" in
 debian) ;;
 *)
  # proxy settings
  export http_proxy=http://proxy.esrf.fr:3128
  export https_proxy=https://proxy.esrf.fr:3128
  export LFS_CROSS_COMPILE_x86=/segfs/linux/dance_sdk/toolchain/i686-nptl-linux-gnu/bin/i686-nptl-linux-gnu-
  export LFS_CROSS_COMPILE_armv7=/segfs/linux/dance_sdk/toolchain/arm-buildroot-linux-uclibcgnueabi/bin/arm-buildroot-linux-uclibcgnueabi-
  ;;
esac
