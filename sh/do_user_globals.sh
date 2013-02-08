case "$HOSTNAME" in
 'PCLAB245')
  # proxy settings
  export http_proxy=http://proxy.esrf.fr:3128/
  export ftp_proxy=ftp://proxy.esrf.fr:3128/
  export all_proxy=socks://proxy.esrf.fr:3128/
  export https_proxy=https://proxy.esrf.fr:3128/
  # toolchains
  export LFS_CROSS_COMPILE_x86=/home/lementec/segfs/repo/dance/local/cross/.build/i686-nptl-linux-gnu/bin/i686-nptl-linux-gnu-
  export LFS_CROSS_COMPILE_armv6=''
  ;;
 'dell')
  export LFS_CROSS_COMPILE_x86=''
  export LFS_CROSS_COMPILE_armv6=/home/texane/x-tools/armv6-rpi-linux-gnueabi/bin/armv6-rpi-linux-gnueabi-
  ;;
esac

# override do_user_globals.sh here
