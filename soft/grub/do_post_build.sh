# precreate partition table, otherwise grub-install not working
# https://wiki.archlinux.org/index.php/GRUB
# cf. chattr note

sector_size=512
mb_size=$((1024 * 1024))
mul_size=$(($mb_size / $sector_size))
mbr_size=1

empty_size=$(($LFS_DISK_EMPTY_SIZE * $mul_size))
boot_size=$(($LFS_DISK_BOOT_SIZE * $mul_size))
boot_off=$(($mbr_size + $empty_size))

tmp_path=`tempfile`
[ -e $tmp_path ] && do_exec rm $tmp_path
if [ $empty_size != 0 ]; then
 echo "1,$empty_size,0," >> $tmp_path
fi

bootpart_type='c'
[ $LFS_DISK_BOOT_FS != 'vfat' ] && bootpart_type='83'
echo "$boot_off,$boot_size,$bootpart_type,*" >> $tmp_path

sudo sh -c "sfdisk --no-reread -f -uS $LFS_DISK_IMAGE < $tmp_path"
rm $tmp_path


# install grub

boot_dir=$LFS_TARGET_INSTALL_DIR/boot

sudo chattr -i $boot_dir/grub/i386-pc/core.img

sudo \
$LFS_HOST_INSTALL_DIR/sbin/grub-install \
--modules=part_msdos \
--boot-directory=$boot_dir \
--target=i386-pc --recheck --force \
$LFS_DISK_DEV

sudo chattr +i $boot_dir/grub/i386-pc/core.img

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
