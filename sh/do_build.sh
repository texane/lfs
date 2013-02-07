#!/usr/bin/env sh


# global variables

export DEV=/dev/sdd
export EMPTY_PART=$DEV\1
export BOOT_PART=$DEV\2
export ROOT_PART=$DEV\3

export KERNEL_VERSION=3.6.11


#
echo partitioning $DEV

# format the sd so that there are 3 partitions
# empty_part is a post mbr gap needed by grub
# boot_part contains the bootable files
# root_part contains the system files

sfdisk --no-reread -u M $DEV <<EOF
0,2,0,
,128,c,*
,,83
EOF

./do_build_bootfs_grub.sh
./do_build_rootfs.sh
