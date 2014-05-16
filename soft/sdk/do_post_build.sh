[ -d $LFS_SDK_DIR ] || mkdir -p $LFS_SDK_DIR

# install sdk/toolchain

[ -d $LFS_SDK_DIR/toolchain ] || mkdir $LFS_SDK_DIR/toolchain

a=`dirname $LFS_CROSS_COMPILE`
b=`dirname $a`
toolchain_vers=`basename $b`
cp -rf $b $LFS_SDK_DIR/toolchain/

# install sdk/kernel/$platform/linux-$LFS_LINUX_VERS

case $LFS_THIS_BOARD_NAME in
 comex) platform=kontron_type10 ;;
 seco_x86) platform=kontron_type10 ;;
 *) platform=$LFS_THIS_BOARD_NAME ;;
esac

p=$LFS_SDK_DIR/kernel/$platform
mkdir -p $p
cp -rf $LFS_SRC_DIR/linux $p/linux-$LFS_LINUX_VERS

# install sdk/deps

deps_dir=$LFS_SDK_DIR/deps/$toolchain_vers

[ -d $deps_dir ] || mkdir -p $deps_dir

l=''
l+=' /include'
l+=' /lib'
l+=' /lib32'
l+=' /lib64'
l+=' /man'
l+=' /share'
l+=' /usr/include'
l+=' /usr/lib'
l+=' /usr/lib32'
l+=' /usr/lib64'
l+=' /usr/share'

for f in $l; do
 source_path=$LFS_TARGET_INSTALL_DIR/$f
 dest_path=$deps_dir/$f
 mkdir -p $deps_dir/`dirname $f`
 cp -rf $source_path $dest_path
done

# install sdk/build scripts

build_dir=$LFS_SDK_DIR/build
[ -d $build_dir ] || mkdir -p $build_dir

lfs_mk=$build_dir/lfs_$platform.mk
echo "LFS_SDK_TOP_DIR ?= $LFS_SDK_DIR" > $lfs_mk
echo 'LFS_SDK_CROSS_COMPILE := $(LFS_SDK_TOP_DIR)/toolchain/'$toolchain_vers'/bin/'$toolchain_vers'-' >> $lfs_mk
echo 'LFS_SDK_DEPS_DIR := $(LFS_SDK_TOP_DIR)/deps/'$toolchain_vers >> $lfs_mk
echo 'LFS_SDK_KERNEL_DIR := $(LFS_SDK_TOP_DIR)/'$platform'/linux-'$LFS_LINUX_VERS >> $lfs_mk

lfs_sh=$build_dir/lfs_$platform.sh
echo "export LFS_SDK_TOP_DIR=$LFS_SDK_DIR" > $lfs_sh
echo 'export LFS_SDK_CROSS_COMPILE=$LFS_SDK_TOP_DIR/toolchain/'$toolchain_vers'/bin/'$toolchain_vers'-' >> $lfs_sh
echo 'export LFS_SDK_DEPS_DIR=$LFS_SDK_TOP_DIR/deps/'$toolchain_vers >> $lfs_sh
echo 'export LFS_SDK_KERNEL_DIR=$LFS_SDK_TOP_DIR/'$platform'/linux-'$LFS_LINUX_VERS >> $lfs_sh
