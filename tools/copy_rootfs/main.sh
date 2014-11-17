#!/usr/bin/env bash

[ -z $TMP_DIR ] && export TMP_DIR=/tmp

function do_unsquash() {
 # require DISK_PATH
 # export ROOTFS_PATH
 # export ROOT_OFF

 tmp_path=`tempfile -d $TMP_DIR`
 [ -e $tmp_path ] && rm -f $tmp_path

 export ROOTFS_PATH=`tempfile -d $TMP_DIR`
 rm -rf $ROOTFS_PATH

 # format: name start end count
 line=(`/sbin/fdisk -l $DISK_PATH | grep Linux`)
 export ROOT_OFF=${line[1]}
 size=${line[2]}
 dd if=$DISK_PATH of=$tmp_path skip=$ROOT_OFF bs=512 count=$size

 unsquashfs -d $ROOTFS_PATH $tmp_path
}

function do_copy() {
 # require SOURCE_PATH
 # require DEST_PATH
 # require ROOTFS_PATH

 cp -rf $SOURCE_PATH $ROOTFS_PATH/$DEST_PATH
}

function do_squash() {
 # require ROOTFS_PATH
 # export SQUASH_PATH

 export SQUASH_PATH=`tempfile -d $TMP_DIR`
 [ -e $SQUASH_PATH ] && rm $SQUASH_PATH
 mksquashfs $ROOTFS_PATH $SQUASH_PATH
}

function do_write() {
 # require SQUASH_PATH
 # require DISK_PATH
 # require ROOT_OFF

 dd if=$SQUASH_PATH of=$DISK_PATH seek=$ROOT_OFF bs=512
}

# usage: main.sh source disk dest
# copy the contents of source_path to disk_path/dest_path
# assumes the linux partition of the disk hosts a squashfs
# example:
# ./main.sh ~/repo/bano/src/base/bano disk /home/root/
# copies the bano directory in rootfs /home/root

export SOURCE_PATH=$1
export DISK_PATH=$2
export DEST_PATH=$3

do_unsquash
do_copy
do_squash
do_write
