#
# provide:
# libepci
# libtst_epci
# efspi
# pcycle
# uirq.ko
# pmem.ko


# select dance_sdk_platform
# CROSS_COMPILE is set by the build environment

case $LFS_THIS_BOARD_NAME in
 comex|seco_x86) dance_sdk_platform='kontron_type10' ;;
 conga_imx6) dance_sdk_platform='conga_imx6' ;;
 seco_imx6) dance_sdk_platform='seco_imx6' ;;
 seco_uimx6) dance_sdk_platform='seco_uimx6' ;;
 rpi3) dance_sdk_platform='seco_imx6' ;;
 *) dance_sdk_platform='local' ;;
esac

if [ -z $DANCE_SDK_ROOT ]; then
 export DANCE_SDK_ROOT=/segfs/linux/dance_sdk
fi

# create rootfs directories

mkdir -p $LFS_TARGET_INSTALL_DIR/lib/dance
mkdir -p $LFS_TARGET_INSTALL_DIR/bin/dance
mkdir -p $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance


# libepci

cd $LFS_THIS_SOFT_SRC/components/libepci/src
make DANCE_SDK_PLATFORM=$dance_sdk_platform devel
cp libepci.{a,so} $LFS_TARGET_INSTALL_DIR/lib/dance/


# libtst_epci

cd $LFS_THIS_SOFT_SRC/components/compat/libtst_epci
make DANCE_SDK_PLATFORM=$dance_sdk_platform install_local
cp -rf install/* $LFS_TARGET_INSTALL_DIR/


# efspi

cd $LFS_THIS_SOFT_SRC/components/libefspi/unit/efspi
make DANCE_SDK_PLATFORM=$dance_sdk_platform
cp -f main $LFS_TARGET_INSTALL_DIR/bin/dance/efspi


# ejtag

cd $LFS_THIS_SOFT_SRC/components/libejtag/unit/ejtag
make DANCE_SDK_PLATFORM=$dance_sdk_platform
cp -f main $LFS_TARGET_INSTALL_DIR/bin/dance/ejtag


# pcycle

cd $LFS_THIS_SOFT_SRC/components/compat/pcycle
make DANCE_SDK_PLATFORM=$dance_sdk_platform install_local
cp -rf install/* $LFS_TARGET_INSTALL_DIR/


# uirq.ko

cd $LFS_THIS_SOFT_SRC/components/libuirq/src/k
make DANCE_SDK_PLATFORM=$dance_sdk_platform
cp linux-$LFS_LINUX_VERS/uirq.ko $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance/uirq.ko


# pmem.ko

cd $LFS_THIS_SOFT_SRC/components/libpmem/src/k
make DANCE_SDK_PLATFORM=$dance_sdk_platform
cp linux-$LFS_LINUX_VERS/pmem.ko $LFS_TARGET_INSTALL_DIR/lib/modules/$LFS_LINUX_VERS/dance/pmem.ko
