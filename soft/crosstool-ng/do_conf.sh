[ -z $LFS_CTNG_VERS ] && return

# do not compile if already exists
[ -e $LFS_CROSS_COMPILE\gcc ] && return

LFS_THIS_SOFT_IS_ENABLED=1
LFS_THIS_SOFT_IS_CROSS_COMPILED=0
LFS_THIS_SOFT_VERS=$LFS_CTNG_VERS
LFS_THIS_SOFT_URL=http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-$LFS_CTNG_VERS.tar.bz2
LFS_THIS_SOFT_BUILD_METHOD=byhand
