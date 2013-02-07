export_if_empty LFS_WORK_DIR $LFS_TOP_DIR/_work
export_if_empty LFS_TAR_DIR $LFS_WORK_DIR/tar
export_if_empty LFS_SRC_DIR $LFS_WORK_DIR/src
export_if_empty LFS_TARGET_INSTALL_DIR $LFS_WORK_DIR/target_install
export_if_empty LFS_HOST_INSTALL_DIR $LFS_WORK_DIR/host_install
export_if_empty LFS_BUILD_DIR $LFS_WORK_DIR/build
export_if_empty LFS_CROSS_COMPILE ''
export_if_empty LFS_HOST_ARCH=`uname -m`
