#!/usr/bin/env sh

a=/home/texane/repo/lfs/tools/update_disk/disk/disk_wip
b=/home/texane/repo/lfs/tools/update_disk/disk/disk_new

sudo losetup -f $a

sudo fdisk -l /dev/loop0
echo

sudo ./a.out $b
echo

sudo fdisk -l /dev/loop0
echo

sudo losetup -d /dev/loop0
