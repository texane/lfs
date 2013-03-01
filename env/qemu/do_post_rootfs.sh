this_dir=$LFS_TOP_DIR/env/$LFS_THIS_ENV_NAME

cp $this_dir/interface.eth0 $LFS_TARGET_INSTALL_DIR/etc/network.d/
cp $this_dir/network.conf $LFS_TARGET_INSTALL_DIR/etc/
cp $this_dir/resolv.conf $LFS_TARGET_INSTALL_DIR/etc/

cp $this_dir/shadow $LFS_TARGET_INSTALL_DIR/etc/

cp $this_dir/10_dropbear $LFS_TARGET_INSTALL_DIR/etc/init.d
chmod 755 $LFS_TARGET_INSTALL_DIR/etc/init.d/10_dropbear
