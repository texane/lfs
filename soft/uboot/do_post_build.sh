is_enabled='no'
[ $LFS_THIS_BOARD_NAME == 'seco_imx6' ] && is_enabled='yes'
[ is_enabled == 'no' ] && return

# jump over partition table
sudo dd conv=notrunc bs=512 seek=2 if=$LFS_THIS_SOFT_SRC/u-boot.imx of=$LFS_DISK_IMAGE

# create and copy environment binary
# for mmc env offset and size, refer to include/configs/mx6solo_seco.h
# env_off in KB
# env_size in bytes
env_off=$((6 * 128))
env_size=$((8 * 1024))

env_bin=$LFS_THIS_SOFT_SRC/u-boot.env.bin
[ -e $env_bin ] && rm $env_bin

$LFS_THIS_SOFT_SRC/tools/mkenvimage \
-s $env_size -o $env_bin $LFS_THIS_BOARD_DIR/uboot.env

sudo dd conv=notrunc bs=1024 seek=$env_off if=$env_bin of=$LFS_DISK_IMAGE
