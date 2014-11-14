is_enabled='no'
[ $LFS_THIS_BOARD_NAME == 'comex' ] && is_enabled='yes'
[ $LFS_THIS_BOARD_NAME == 'seco_x86' ] && is_enabled='yes'
[ $LFS_THIS_BOARD_NAME == 'conga_imx6' ] && is_enabled='yes'
[ $LFS_THIS_BOARD_NAME == 'seco_imx6' ] && is_enabled='yes'
[ $LFS_THIS_BOARD_NAME == 'seco_uimx6' ] && is_enabled='yes'
[ $is_enabled == 'no' ] && return

LFS_THIS_SOFT_IS_ENABLED=1
LFS_THIS_SOFT_URL=byhand
LFS_THIS_SOFT_BUILD_METHOD=byhand
LFS_THIS_SOFT_DEPS='pciutils'
