cd $LFS_THIS_SOFT_SRC

# LD_LIBRARY_PATH ctng compilation
unset LD_LIBRARY_PATH

# install ctng for host
make clean distclean
./bootstrap
./configure --prefix=$LFS_HOST_INSTALL_DIR
make install

# configure the toolchain
cp $LFS_THIS_BOARD_DIR/crosstool-ng-$LFS_CTNG_VERS.config .config

file_path=./.config

# replace CT_PREFIX_DIR
key='CT_PREFIX_DIR'
fu=`dirname $LFS_CROSS_COMPILE`
bar=${fu/'/'bin/}
val=${bar//\//\\\/}
sed -i -e "s/^\($key\)=\"\(.*\)\"$/\1=\"$val\"/g" $file_path

# replace CT_KERNEL_VERSION
key='CT_KERNEL_VERSION'
val=$LFS_LINUX_VERS
sed -i -e "s/^\($key\)=\"\(.*\)\"$/\1=\"$val\"/g" $file_path

# replace CT_KERNEL_V_x_y_z
vers=${LFS_LINUX_VERS//./_}
sed -i -e "s/^CT_KERNEL_V_\(.*\)=y$/CT_KERNEL_V_$vers=y/g" $file_path

# some components (ie. gcc-4.6.0) have to be patched. we stop the build
# after tarballs have been extracted, apply any required patch, then
# restart the build.

$LFS_HOST_INSTALL_DIR/bin/ct-ng build STOP=libc_check_config

if [ -d $LFS_THIS_SOFT_SRC/.build/src/gcc-4.6.0 ]; then
 < $LFS_THIS_SOFT_DIR/gcc-4.6.0.diff \
 patch -p1 -d $LFS_THIS_SOFT_SRC/.build/src/gcc-4.6.0
fi

$LFS_HOST_INSTALL_DIR/bin/ct-ng build
