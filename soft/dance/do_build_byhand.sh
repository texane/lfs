#
# provide:
# libepci
# libtst_epci
# flash, fread, fload
# pcycle
# pcidrvgen, epcidrv


# libepci

cd $LFS_THIS_SOFT_SRC/linuxcore/libepci/src

# CROSS_COMPILE is set by the build environment
make platform=kontron_type10 devel

mkdir -p $LFS_TARGET_INSTALL_DIR/lib/dance
cp libepci.{a,so} $LFS_TARGET_INSTALL_DIR/lib/dance/

mkdir -p $LFS_TARGET_INSTALL_DIR/include/dance
cp {common,libepci}.h $LFS_TARGET_INSTALL_DIR/include/dance/

cp ../../driver/epcidrv/src/epcidrv.h $LFS_TARGET_INSTALL_DIR/include/dance/
cp ../../driver/pcidrvgen/src/pcidrvgen.h $LFS_TARGET_INSTALL_DIR/include/dance/


# libtst_epci

cd $LFS_THIS_SOFT_SRC/linuxcore/compat/libtst_epci
make platform=kontron_type10 install_local
cp -rf install/* $LFS_TARGET_INSTALL_DIR/


# flash, fread, fload

cd $LFS_THIS_SOFT_SRC/linuxcore/compat/fspi
make platform=kontron_type10 install_local
cp -rf install/* $LFS_TARGET_INSTALL_DIR/


# pcycle

cd $LFS_THIS_SOFT_SRC/linuxcore/compat/pcycle
make platform=kontron_type10 install_local
cp -rf install/* $LFS_TARGET_INSTALL_DIR/


# pcidrvgen, epcidrv

mkdir -p $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance

cd $LFS_THIS_SOFT_SRC/linuxcore/driver/epcidrv/src
# CROSS_COMPILE is set by the build environment
make platform=kontron_type10
cp linux-$LFS_LINUX_VERS/epcidrv.ko $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance/epcidrv.ko

cd $LFS_THIS_SOFT_SRC/linuxcore/driver/pcidrvgen/src
# CROSS_COMPILE is set by the build environment
make platform=kontron_type10
cp linux-$LFS_LINUX_VERS/pcidrvgen.ko $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance/pcidrvgen.ko
