cp $LFS_THIS_BOARD_DIR/uboot.config $LFS_THIS_SOFT_SRC/tools/sconfig

cross=${LFS_CROSS_COMPILE//\//\\/}
sed -i -e "s/LFS_CROSS_COMPILE/$cross/g" $LFS_THIS_SOFT_SRC/tools/sconfig > /dev/null 2>&1
cd $LFS_THIS_SOFT_SRC && ./compile.sh
