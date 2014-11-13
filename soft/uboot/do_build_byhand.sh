cp $LFS_THIS_BOARD_DIR/uboot.config $LFS_THIS_SOFT_SRC/tools/sconfig
sed -i -e "s/LFS_CROSS_COMPILE/$LFS_CROSS_COMPILE/g" $LFS_THIS_SOFT_SRC/tools/sconfig > /dev/null 2>&1
cd $LFS_THIS_SOFT_SRC && ./compile.sh
