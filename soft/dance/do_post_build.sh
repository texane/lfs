# install init scripts
initd_dir=$LFS_TARGET_INSTALL_DIR/etc/init.d
[ -d $initd_dir ] || mkdir -p $initd_dir
cp $LFS_THIS_SOFT_DIR/etc/init.d/20_dance $initd_dir
chmod 755 $initd_dir/20_dance

# install dance profile
[ -d $LFS_TARGET_INSTALL_DIR/etc/dance ] || mkdir $LFS_TARGET_INSTALL_DIR/etc/dance
cp $LFS_THIS_SOFT_DIR/etc/dance/profile $LFS_TARGET_INSTALL_DIR/etc/dance/profile
chmod 755 -R $LFS_TARGET_INSTALL_DIR/etc/dance/profile
