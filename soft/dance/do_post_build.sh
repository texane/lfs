# install init scripts
initd_dir=$LFS_TARGET_INSTALL_DIR/etc/init.d
[ -d $initd_dir ] || mkdir -p $initd_dir
cp $LFS_THIS_SOFT_DIR/etc/init.d/20_dance $initd_dir
chmod 755 $initd_dir/20_dance

# install dance profile
[ -d $LFS_TARGET_INSTALL_DIR/etc/dance ] || mkdir $LFS_TARGET_INSTALL_DIR/etc/dance
cp $LFS_THIS_SOFT_DIR/etc/dance/profile.local $LFS_TARGET_INSTALL_DIR/etc/dance/profile.local
chmod 755 $LFS_TARGET_INSTALL_DIR/etc/dance/profile.local
cp $LFS_THIS_SOFT_DIR/etc/dance/profile.segfs $LFS_TARGET_INSTALL_DIR/etc/dance/profile.segfs
chmod 755 $LFS_TARGET_INSTALL_DIR/etc/dance/profile.segfs
ln -s profile.local $LFS_TARGET_INSTALL_DIR/etc/dance/profile
