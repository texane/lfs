export http_proxy=proxy.esrf.fr:3128
export https_proxy=proxy.esrf.fr:3128
export LFS_CROSS_COMPILE=/segfs/linux/dance_sdk/toolchain/arm-ctng-linux-uclibcgnueabi/bin/arm-unknown-linux-uclibcgnueabi-
export LFS_TARGET_ARCH=arm

base_dir=/buffer/PCLAB2451/lementec/tmp/lfs

export LFS_TARGET_INSTALL_DIR=$base_dir/target_install
src_dir=$base_dir/src
tar_dir=$base_dir/tar

for d in $LFS_TARGET_INSTALL_DIR $src_dir $tar_dir; do
 mkdir -p $d ;
done

export LFS_THIS_SOFT_TAR_EXT=.tar.gz 
export LFS_THIS_SOFT_TAR=$tar_dir/tango$LFS_THIS_SOFT_TAR_EXT
export LFS_THIS_SOFT_SRC=$src_dir/tango

# ./do_retrieve_byhand.sh
[ -d $LFS_THIS_SOFT_SRC ] && rm -rf $LFS_THIS_SOFT_SRC
mkdir $LFS_THIS_SOFT_SRC
tar xvf $LFS_THIS_SOFT_TAR --strip 1 -C $LFS_THIS_SOFT_SRC
./do_build_byhand.sh
