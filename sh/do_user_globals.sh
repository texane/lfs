case "$HOSTNAME" in
 'PCLAB245')
  # proxy settings
  export http_proxy=http://proxy.esrf.fr:3128
  export ftp_proxy=ftp://proxy.esrf.fr:3128
  export all_proxy=socks://proxy.esrf.fr:3128
  export https_proxy=https://proxy.esrf.fr:3128
  export LFS_CROSS_COMPILE=/home/lementec/segfs/repo/dance/local/cross/.build/i686-nptl-linux-gnu/bin/i686-nptl-linux-gnu-
  ;;
 'dell')
  export LFS_CROSS_COMPILE=''
  ;;
esac

# override do_user_globals.sh here
