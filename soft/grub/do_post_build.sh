boot_dir=$LFS_TARGET_INSTALL_DIR/boot

sudo \
$LFS_HOST_INSTALL_DIR/sbin/grub-install \
--modules=part_msdos \
--boot-directory=$boot_dir \
$LFS_DISK_DEV

if [ "$LFS_THIS_ENV_NAME" == "stick" ]; then
 grub_config=$LFS_THIS_SOFT_DIR/grub_stick.cfg
else
 case $LFS_THIS_BOARD_NAME in
  vcomex|backend)
   grub_config=$LFS_THIS_SOFT_DIR/grub_vcomex.cfg
   ;;
  quadmo)
   grub_config=$LFS_THIS_SOFT_DIR/grub_quadmo.cfg
   ;;
  *)
   grub_config=$LFS_THIS_SOFT_DIR/grub.cfg
   ;;
 esac
fi

cp $grub_config $boot_dir/grub/grub.cfg

sed -i -e "s/LFS_LINUX_VERS/$LFS_LINUX_VERS/g" $boot_dir/grub/grub.cfg > /dev/null 2>&1
