is_enabled='no'
[ $LFS_THIS_BOARD_NAME == 'seco_imx6' ] && is_enabled='yes'
[ $LFS_THIS_BOARD_NAME == 'seco_uimx6' ] && is_enabled='yes'
[ $is_enabled == 'no' ] && return

LFS_THIS_SOFT_IS_ENABLED=1
LFS_THIS_SOFT_URL=file:///segfs/linux/dance_sdk/tarballs/$LFS_THIS_BOARD_NAME/uboot.tar.gz
LFS_THIS_SOFT_BUILD_METHOD=byhand
