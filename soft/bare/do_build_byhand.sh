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

d=$LFS_TARGET_INSTALL_DIR/bin/dance
mkdir -p $d

cd $LFS_THIS_SOFT_SRC/instruments/bare/firmware/controller
make DANCE_SDK_PLATFORM=$dance_sdk_platform DANCE_SDK_DEV_DIR=$LFS_THIS_SOFT_SRC/components devel
cp $LFS_THIS_SOFT_SRC/instruments/bare/firmware/controller/bare $d/bare
