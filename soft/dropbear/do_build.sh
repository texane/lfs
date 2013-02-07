# top is asking the build method
if [ $LFS_DO_BUILD_BYHAND == 0 ]; then
 LFS_RETURN_VALUE=byhand
 return
fi

# top is asking us to perform the build by hand

# install the required components
$LFS_TOP_DIR/sh/do_install_soft.sh 'zlib'

cd $LFS_THIS_SOFT_SRC

make clean distclean

CC=$LFS_CROSS_COMPILE\gcc \
./configure \
--prefix=$LFS_TARGET_INSTALL_DIR \
--with-zlib=$LFS_TARGET_INSTALL_DIR

make PROGRAMS="dropbear dropbearkey dbclient scp" MULTI=1

# install by hand

mkdir -p $LFS_TARGET_INSTALL_DIR/usr/bin/
cp dropbearmulti $LFS_TARGET_INSTALL_DIR/usr/bin/
ln -s dropbearmulti $LFS_TARGET_INSTALL_DIR/usr/bin/dbclient
ln -s dropbearmulti $LFS_TARGET_INSTALL_DIR/usr/bin/scp
ln -s dropbearmulti $LFS_TARGET_INSTALL_DIR/usr/bin/dropbear
ln -s dropbearmulti $LFS_TARGET_INSTALL_DIR/usr/bin/dropbearkey

mkdir -p $LFS_TARGET_INSTALL_DIR/etc/dropbear
cp $LFS_THIS_SOFT_DIR/dropbear_dss_host_key $LFS_TARGET_INSTALL_DIR/etc/dropbear/
cp $LFS_THIS_SOFT_DIR/dropbear_rsa_host_key $LFS_TARGET_INSTALL_DIR/etc/dropbear/

exit 0
