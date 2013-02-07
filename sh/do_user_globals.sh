if [ "PCLAB245" = "$HOSTNAME" ]; then
 # proxy settings
 export http_proxy=http://proxy.esrf.fr:3128
 export ftp_proxy=ftp://proxy.esrf.fr:3128
 export all_proxy=socks://proxy.esrf.fr:3128
 export https_proxy=https://proxy.esrf.fr:3128
fi

# override do_user_globals.sh here
export LFS_CROSS_COMPILE=/home/lementec/segfs/repo/dance/local/cross/.build/i686-nptl-linux-gnu/bin/i686-nptl-linux-gnu-