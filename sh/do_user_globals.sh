# toolchains
export LFS_CROSS_COMPILE_x86=$LFS_HOST_INSTALL_DIR/i686-nptl-linux-gnu/bin/i686-nptl-linux-gnu-
export LFS_CROSS_COMPILE_x86_64=/usr/bin/
export LFS_CROSS_COMPILE_armv6=$LFS_HOST_INSTALL_DIR/armv6-rpi-linux-gnueabi/bin/armv6-rpi-linux-gnueabi-

case "$HOSTNAME" in
 'PCLAB245')
  # proxy settings
  export http_proxy=http://proxy.esrf.fr:3128
  export https_proxy=https://proxy.esrf.fr:3128
  # DONT_USE: ftp_proxy=ftp://proxy.esrf.fr:3128
  # DONT_USE: all_proxy=socks://proxy.esrf.fr:3128
  export LFS_CROSS_COMPILE_x86=/segfs/linux/dance_sdk/toolchain/i686-nptl-linux-gnu/bin/i686-nptl-linux-gnu-
  ;;
 'pclab245bis')
  export http_proxy=http://proxy.esrf.fr:3128
  export https_proxy=https://proxy.esrf.fr:3128
  export LFS_CROSS_COMPILE_x86=/segfs/linux/dance_sdk/toolchain/i686-nptl-linux-gnu/bin/i686-nptl-linux-gnu-
  ;;
esac
