if [ $LFS_DO_BUILD_BYHAND == 0 ]; then
 LFS_RETURN_VALUE=byhand
 return
fi

cp -rf $LFS_THIS_SOFT_SRC/* $LFS_TARGET_INSTALL_DIR/
