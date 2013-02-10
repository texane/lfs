etc_dir=$LFS_TARGET_INSTALL_DIR/etc

initd_dir=$etc_dir/init.d
[ -d $initd_dir ] || mkdir -p $initd_dir
cp $LFS_THIS_SOFT_DIR/10_dropbear $initd_dir

[ -d $etc_dir/dropbear ] || mkdir $etc_dir/dropbear
cp $LFS_THIS_SOFT_DIR/dropbear_dss_host_key $etc_dir/dropbear/
cp $LFS_THIS_SOFT_DIR/dropbear_rsa_host_key $etc_dir/dropbear/
