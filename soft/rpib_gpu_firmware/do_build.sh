if [ $LFS_DO_BUILD_BYHAND == 0 ]; then
 LFS_RETURN_VALUE=byhand
 return
fi

boot_dir=$LFS_TARGET_INSTALL_DIR/boot
mkdir -p $boot_dir
cp -rf $LFS_THIS_SOFT_SRC/* $boot_dir/
