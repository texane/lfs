boot_dir=$LFS_TARGET_INSTALL_DIR/boot
kernel_name=vmlinuz-$LFS_LINUX_VERS
mkdir -p $boot_dir && cp -rf $LFS_THIS_SOFT_SRC/* $boot_dir/
echo "kernel $kernel_name" >> $boot_dir/config.txt
