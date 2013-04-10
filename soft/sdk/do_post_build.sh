[ -d $LFS_SDK_DIR ] || mkdir -p $LFS_SDK_DIR

# install sdk/toolchain

[ -d $LFS_SDK_DIR/toolchain ] || mkdir $LFS_SDK_DIR/toolchain

a=`dirname $LFS_CROSS_COMPILE`
b=`dirname $a`
cp -rf $b $LFS_SDK_DIR/toolchain/

# install sdk/kernel/$platform/linux-$LFS_LINUX_VERS
case $LFS_THIS_BOARD_NAME in
 comex) platform=kontron_type10 ;;
 *) platform=unknown ;;
esac

p=$LFS_SDK_DIR/kernel/$platform
mkdir -p $p
cp -rf $LFS_SRC_DIR/linux $p/linux-$LFS_LINUX_VERS

# install sdk/deps

deps_dir=$LFS_SDK_DIR/deps

[ -d $deps_dir ] || mkdir -p $deps_dir

l=''
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
 cp -rf $LFS_TARGET_INSTALL_DIR/$f $deps_dir/
done
