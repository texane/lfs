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

# build a toolchain
$LFS_HOST_INSTALL_DIR/bin/ct-ng build
