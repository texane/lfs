boot_dir=$LFS_TARGET_INSTALL_DIR/boot

sudo \
$LFS_HOST_INSTALL_DIR/sbin/grub-install \
--boot-directory=$boot_dir \
$LFS_DISK_DEV

cp $LFS_THIS_SOFT_DIR/grub.cfg $boot_dir/grub/
sed -i -e "s/LFS_LINUX_VERS/$LFS_LINUX_VERS/g" $boot_dir/grub/grub.cfg
