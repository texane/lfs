# compile install libepci

cd $LFS_THIS_SOFT_SRC/linuxcore/libepci/src

# CROSS_COMPILE is set by the build environment
make platform=kontron_type10
mkdir -p $LFS_TARGET_INSTALL_DIR/lib/dance
cp libepci.{a,so} $LFS_TARGET_INSTALL_DIR/lib/dance/


# compile install pcidrvgen and epcidrv modules

mkdir -p $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance

cd $LFS_THIS_SOFT_SRC/linuxcore/driver/epcidrv/src
# CROSS_COMPILE is set by the build environment
make platform=kontron_type10
cp linux-$LFS_LINUX_VERS/epcidrv.ko $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance/epcidrv.ko

cd $LFS_THIS_SOFT_SRC/linuxcore/driver/pcidrvgen/src
# CROSS_COMPILE is set by the build environment
make platform=kontron_type10
cp linux-$LFS_LINUX_VERS/pcidrvgen.ko $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance/pcidrvgen.ko
