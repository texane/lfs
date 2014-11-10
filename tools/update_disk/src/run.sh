#!/usr/bin/env sh

a=/home/texane/repo/lfs/tools/update_disk/disk/disk_wip
b=/home/texane/repo/lfs/tools/update_disk/disk/disk_new
sudo losetup -f $a
sudo ./a.out $b
sudo fdisk -l /dev/loop0
sudo losetup -d /dev/loop0
