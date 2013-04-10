cd $LFS_THIS_SOFT_SRC

# make both static and shared libs

make install \
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

exit 0
