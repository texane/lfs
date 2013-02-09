basename=`basename $LFS_CROSS_COMPILE`
dirname=`dirname $LFS_CROSS_COMPILE`
sysroot_dir=$dirname/../${basename%?}/sysroot
cp -rf $sysroot_dir/* $LFS_TARGET_INSTALL_DIR/
chmod -R 755 $LFS_TARGET_INSTALL_DIR
