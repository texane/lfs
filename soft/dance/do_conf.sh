is_enabled='no'
[ $LFS_THIS_BOARD_NAME == 'comex' ] && is_enabled='yes'
[ $LFS_THIS_BOARD_NAME == 'quadmo' ] && is_enabled='yes'
[ $LFS_THIS_BOARD_NAME == 'qseven' ] && is_enabled='yes'
[ $LFS_THIS_BOARD_NAME == 'seco_imx6' ] && is_enabled='yes'
[ $is_enabled == 'no' ] && return

LFS_THIS_SOFT_IS_ENABLED=1
LFS_THIS_SOFT_URL=svn://https://gaia.esrf.fr/svn/ISDDcommon/Projects/Dance
LFS_THIS_SOFT_BUILD_METHOD=byhand
LFS_THIS_SOFT_DEPS='pciutils'
