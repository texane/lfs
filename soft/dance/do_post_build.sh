initd_dir=$LFS_TARGET_INSTALL_DIR/etc/init.d
[ -d $initd_dir ] || mkdir -p $initd_dir
cp $LFS_THIS_SOFT_DIR/10_pcidrvgen $initd_dir
chmod 755 $initd_dir/10_pcidrvgen
cp $LFS_THIS_SOFT_DIR/10_epcidrv $initd_dir
chmod 755 $initd_dir/10_epcidrv
