basename=`basename $LFS_CROSS_COMPILE`
dirname=`dirname $LFS_CROSS_COMPILE`
sysroot_dir=$dirname/../${basename%?}/sysroot

# reduce system size by removing .la and .a files
n=${#sysroot_dir}
l=`find $sysroot_dir | grep -v '.a$' | grep -v '.la$'`
for s in $l; do
 d=$LFS_TARGET_INSTALL_DIR/${s:n}
 mkdir -p `dirname $d` 2> /dev/null
 if [ -d $d ]; then
  mkdir -p $d 2> /dev/null
 else
  cp -P $s $d 2> /dev/null
 fi
done

chmod -f -R 755 $LFS_TARGET_INSTALL_DIR
