this_dir=$LFS_TOP_DIR/env/$LFS_THIS_ENV_NAME
boot_dir=$LFS_TARGET_INSTALL_DIR/boot

cp $this_dir/interface.eth0 $LFS_TARGET_INSTALL_DIR/etc/network.d/
cp $this_dir/network.conf $LFS_TARGET_INSTALL_DIR/etc/
cp $this_dir/resolv.conf $LFS_TARGET_INSTALL_DIR/etc/

cp $this_dir/shadow $LFS_TARGET_INSTALL_DIR/etc/

cp $this_dir/10_dropbear $LFS_TARGET_INSTALL_DIR/etc/init.d
chmod 755 $LFS_TARGET_INSTALL_DIR/etc/init.d/10_dropbear

cp $this_dir/grub.cfg $boot_dir/grub/grub.cfg
sed -i -e "s/LFS_LINUX_VERS/$LFS_LINUX_VERS/g" $boot_dir/grub/grub.cfg > /dev/null 2>&1

# no cross compile, copy local libs
cp -rf /lib/x86_64-linux-gnu $LFS_TARGET_INSTALL_DIR/lib/
cp -rf /lib64 $LFS_TARGET_INSTALL_DIR/
