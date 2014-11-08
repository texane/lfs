#!/usr/bin/env bash

[ -z $1 ] && ( echo 'missing disk path'; exit -1; )
[ -z $2 ] && ( echo 'missing mount path'; exit -1; )

disk_path=$1
mount_path=$2

# format: name start end count
line=(`/sbin/fdisk -l $disk_path | grep Linux`)
off=$((${line[1]} * 512))
size=$((${line[2]} * 512))

loop_path=`sudo losetup --show -f --offset=$off --sizelimit=$size $disk_path`
[ $? = 0 ] || ( echo 'losetup failed'; exit -1; )

sudo mount $loop_path $mount_path
[ $? = 0 ] || ( echo 'mount failed'; sudo losetup -d $loop_path; exit -1; )

# on success, caller must umount and losetup -d when done
echo $loop_path $mount_path
