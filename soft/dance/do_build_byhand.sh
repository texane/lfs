mkdir -p $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance

cd $LFS_THIS_SOFT_SRC/linuxcore/driver/epcidrv/src
CROSS_COMPILE=$LFS_CROSS_COMPILE make comex
cp linux-$LFS_LINUX_VERS/epcidrv.ko $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance/epcidrv.ko

cd $LFS_THIS_SOFT_SRC/linuxcore/driver/pcidrvgen/src
CROSS_COMPILE=$LFS_CROSS_COMPILE make comex
cp linux-$LFS_LINUX_VERS/pcidrvgen.ko $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance/pcidrvgen.ko

cd $LFS_THIS_SOFT_SRC/linuxcore/libepci/src
CROSS_COMPILE=$LFS_CROSS_COMPILE make
mkdir -p $LFS_TARGET_INSTALL_DIR/usr/lib
cp libepci.so $LFS_TARGET_INSTALL_DIR/usr/lib/libepci.so
