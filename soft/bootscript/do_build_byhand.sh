if [ $LFS_THIS_BOARD_NAME == 'conga_imx6' ]; then

 # generate bootscript in rootfs

 src_path=$LFS_THIS_SOFT_DIR/6q_bootscript.in

 # note: must be installed in the first partition
 # as required by congatech uboot configuration.
 # in our case, the first partition is /boot
 dst_path=$LFS_TARGET_INSTALL_DIR/boot/6q_bootscript

 /segfs/linux/dance_sdk/toolchain/arm-buildroot-linux-uclibcgnueabi/usr/bin/mkimage \
 -T script -C none -n 'QMX6 boot script' -d $src_path $dst_path

elif [ $LFS_THIS_BOARD_NAME == 'bbb' ]; then

 dst_path=$LFS_TARGET_INSTALL_DIR/boot/uEnv.txt
 cp -f $LFS_THIS_BOARD_DIR/uEnv.txt $dst_path
 # key=initrd_file
 # val=initrd.img-$LFS_LINUX_VERS
 # sudo sed -i -e "s/^\($key\)=\(.*\)$/\1=$val/g" $dst_path

fi
