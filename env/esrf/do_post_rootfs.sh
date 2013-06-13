this_dir=$LFS_TOP_DIR/env/$LFS_THIS_ENV_NAME

cp $this_dir/interface.eth0 $LFS_TARGET_INSTALL_DIR/etc/network.d/
cp $this_dir/network.conf $LFS_TARGET_INSTALL_DIR/etc/
cp $this_dir/resolv.conf $LFS_TARGET_INSTALL_DIR/etc/

cp $this_dir/10_segfs $LFS_TARGET_INSTALL_DIR/etc/init.d
mkdir -p $LFS_TARGET_INSTALL_DIR/segfs
chmod 755 $LFS_TARGET_INSTALL_DIR/etc/init.d/10_segfs

cp $this_dir/shadow $LFS_TARGET_INSTALL_DIR/etc/

cp $this_dir/ash_profile $LFS_TARGET_INSTALL_DIR/home/root/.profile
chmod 755 $LFS_TARGET_INSTALL_DIR/home/root/.profile

cp $this_dir/inittab $LFS_TARGET_INSTALL_DIR/etc/
