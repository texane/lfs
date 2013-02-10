# http://www.gnu.org/software/grub/

[ -z $LFS_GRUB_VERS ] && return

LFS_THIS_SOFT_IS_ENABLED=1
LFS_THIS_SOFT_IS_CROSS_COMPILED=0
LFS_THIS_SOFT_VERS=$LFS_GRUB_VERS
LFS_THIS_SOFT_URL=ftp://ftp.gnu.org/gnu/grub/grub-$LFS_GRUB_VERS.tar.gz
LFS_THIS_SOFT_BUILD_METHOD=byhand
