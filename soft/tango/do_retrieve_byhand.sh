# assume LFS_THIS_SOFT_TAR
# assume LFS_THIS_SOFT_TAR_EXT

function do_retrieve_extract {
 tar_url=$1
 tar_dir=$2

 tar_name=`basename $tar_url`

 case $tar_name in
  *.tar)
   ext='.tar'
   opt='xvf'
   ;;
  *.tar.gz)
   ext='.tar.gz'
   opt='xzvf'
   ;;
  *.tgz)
   ext='.tgz'
   opt='xzvf'
   ;;
  *.tar.bz2)
   ext='.tar.bz2'
   opt='xjvf'
   ;;
 esac

 tar_path=$tar_dir$ext
 wget $tar_url -O $tar_path
 mkdir $tar_dir
 tar $opt $tar_path --strip 1 -C $tar_dir
 rm $tar_path
}

# remove trailing extension
tmp_dir=${LFS_THIS_SOFT_TAR::-${#LFS_THIS_SOFT_TAR_EXT}}
mkdir -p $tmp_dir

# zeromq
do_retrieve_extract \
http://download.zeromq.org/zeromq-4.1.0-rc1.tar.gz \
$tmp_dir/zeromq

# omniorb
do_retrieve_extract \
http://optimate.dl.sourceforge.net/project/omniorb/omniORB/omniORB-4.1.6/omniORB-4.1.6.tar.bz2 \
$tmp_dir/omniORB

# tango
do_retrieve_extract \
http://cznic.dl.sourceforge.net/project/tango-cs/tango-8.1.2c.tar.gz \
$tmp_dir/tango

# make soft tarball
cd `dirname $tmp_dir`
tar czvf $LFS_THIS_SOFT_TAR `basename $tmp_dir`
rm -rf $tmp_dir
