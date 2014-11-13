is_enabled='no'
[ $LFS_THIS_BOARD_NAME == 'seco_imx6' ] && is_enabled='yes'
[ is_enabled == 'no' ] && return

# jump over partition table
sudo dd conv=notrunc bs=512 seek=2 if=$LFS_THIS_SOFT_SRC/u-boot.imx of=$LFS_DISK_IMAGE
