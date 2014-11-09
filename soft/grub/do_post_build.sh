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
  vcomex|backend|gen_x86_64)
   grub_config=$LFS_THIS_SOFT_DIR/grub_vcomex.cfg
   ;;
  seco_x86)
   grub_config=$LFS_THIS_SOFT_DIR/grub_seco_x86.cfg
   ;;
  *)
   grub_config=$LFS_THIS_SOFT_DIR/grub.cfg
   ;;
 esac
fi

cp $grub_config $boot_dir/grub/grub.cfg

sed -i -e "s/LFS_LINUX_VERS/$LFS_LINUX_VERS/g" $boot_dir/grub/grub.cfg > /dev/null 2>&1
