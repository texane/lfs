# generate bootscript in rootfs

src_path=$LFS_THIS_SOFT_DIR/6q_bootscript.in

# note: must be installed in the first partition
# as required by congatech uboot configuration.
# in our case, the first partition is /boot
dst_path=$LFS_TARGET_INSTALL_DIR/boot/6q_bootscript

/segfs/linux/dance_sdk/toolchain/arm-buildroot-linux-uclibcgnueabi/usr/bin/mkimage \
-T script -C none -n 'QMX6 boot script' -d $src_path $dst_path
