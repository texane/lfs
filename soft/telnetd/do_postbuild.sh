initd_dir=$LFS_TARGET_INSTALL_DIR/etc/init.d
[ -d $initd_dir ] || mkdir -p $initd_dir
cp $LFS_THIS_SOFT_DIR/10_telnetd $initd_dir
chmod 755 $initd_dir/10_telnetd
