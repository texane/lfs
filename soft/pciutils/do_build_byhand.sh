cd $LFS_THIS_SOFT_SRC

# make both static and shared libs

# required to complete the clean
rm -f lib/config.{h,mk} >/dev/null 2>&1

make clean install \
CROSS_COMPILE=$LFS_CROSS_COMPILE \
PREFIX=$LFS_TARGET_INSTALL_DIR \
SHARED=yes \
ZLIB=no \
DNS=no

make install-lib \
CROSS_COMPILE=$LFS_CROSS_COMPILE \
PREFIX=$LFS_TARGET_INSTALL_DIR \
SHARED=yes \
ZLIB=no \
DNS=no

# required to complete the clean
rm -f lib/config.{h,mk} >/dev/null 2>&1

make clean install \
CROSS_COMPILE=$LFS_CROSS_COMPILE \
PREFIX=$LFS_TARGET_INSTALL_DIR \
SHARED=no \
ZLIB=no \
DNS=no

make install-lib \
CROSS_COMPILE=$LFS_CROSS_COMPILE \
PREFIX=$LFS_TARGET_INSTALL_DIR \
SHARED=no \
ZLIB=no \
DNS=no

[ -e $LFS_TARGET_INSTALL_DIR/sbin/lspci ] && \
chmod 755 $LFS_TARGET_INSTALL_DIR/sbin/lspci

exit 0
