#!/usr/bin/env bash

# usage:
# ./main.sh template_disk_path inst_path
# where:
# template_disk_path the template disk to use
# inst_path the instrument binary path

dot_dir=`dirname $0`

[ -z $1 ] && echo 'missing template disk path' && exit -1
[ -z $2 ] && echo 'missing instrument binary path' && exit -1

disk_path=$1
inst_path=$2

inst_dir=`dirname $inst_path`
inst_name=`basename $inst_path`

[ -z $TMP_DIR ] && export TMP_DIR=/tmp
prof_tmp_path=`tempfile -d $TMP_DIR`
disk_tmp_path=`tempfile -d $TMP_DIR`
chmod 755 $disk_tmp_path

# copy template disk
cp $disk_path $disk_tmp_path

# create profile file
echo '[ -z $DANCE_TOP_DIR ] && export DANCE_TOP_DIR='$inst_dir > $prof_tmp_path
echo 'export DANCE_BIN_DIR=$DANCE_TOP_DIR' >> $prof_tmp_path
echo 'export DANCE_LIB_DIR=/lib/dance' >> $prof_tmp_path
echo 'export DANCE_MOD_DIR=/lib/modules/`uname -r`/dance' >> $prof_tmp_path
echo 'export DANCE_APP_NAMES='$inst_name >> $prof_tmp_path

# copy profile to new disk
$dot_dir/../copy_rootfs/main.sh \
$prof_tmp_path $disk_tmp_path /etc/dance/profile.segfs

# report
echo "new disk created in $disk_tmp_path"

# clean
rm $prof_tmp_path
