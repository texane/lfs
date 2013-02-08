#!/usr/bin/env sh

ROOTFS_PREFIX_DIR=/home/lementec/repo/dance/local
ROOTFS_BASE_DIR=$ROOTFS_PREFIX_DIR/rootfs_base
ROOTFS_BUSYBOX_DIR=$ROOTFS_PREFIX_DIR/rootfs_busybox
ROOTFS_DROPBEAR_DIR=$ROOTFS_PREFIX_DIR/rootfs_dropbear
ROOTFS_ZLIB_DIR=$ROOTFS_PREFIX_DIR/rootfs_zlib
ROOTFS_MODULES_DIR=$ROOTFS_PREFIX_DIR/rootfs_modules
ROOTFS_PCIUTILS_DIR=$ROOTFS_PREFIX_DIR/rootfs_pciutils
ROOTFS_CROSSROOT_DIR=/home/lementec/segfs/repo/dance/local/cross/.build/i686-nptl-linux-gnu/i686-nptl-linux-gnu/sysroot
ROOTFS_PCIDRVGEN_DIR=/home/lementec/segfs/repo/dance/src/pcidrvgen/src/linux-$KERNEL_VERSION
ROOTFS_PCYCLE_DIR=/home/lementec/segfs/repo/dance/src/pcycle
ROOTFS_FLASH_DIR=/home/lementec/segfs/repo/dance/src/flash


#
echo formating $ROOT_PART

mkfs.ext2 $ROOT_PART
tune2fs -c -1 $ROOT_PART

MOUNT_DIR=/tmp/rootfs
[ -d $MOUNT_DIR ] || mkdir $MOUNT_DIR
mount $ROOT_PART $MOUNT_DIR


#
echo installing $ROOT_PART

cp -rf $ROOTFS_BASE_DIR/* $MOUNT_DIR

# base system tools
cp -rf $ROOTFS_BUSYBOX_DIR/* $MOUNT_DIR

# dropbear
# keys generated with:
# dropbearkey -t rsa -f $ROOTFS_DROPBEAR_DIR/etc/dropbear/dropbear_rsa_host_key
# dropbearkey -t dss -f $ROOTFS_DROPBEAR_DIR/etc/dropbear/dropbear_dss_host_key
cp -rf $ROOTFS_DROPBEAR_DIR/* $MOUNT_DIR/

# third libs
cp -rf $ROOTFS_ZLIB_DIR/* $MOUNT_DIR/
cp -rf $ROOTFS_CROSSROOT_DIR/* $MOUNT_DIR/
cp -rf $ROOTFS_PCIUTILS_DIR/* $MOUNT_DIR/

# kernel modules
cp -rf $ROOTFS_MODULES_DIR/* $MOUNT_DIR/

# pcidrvgen
mkdir $MOUNT_DIR/lib/modules/$KERNEL_VERSION/dance
cp $ROOTFS_PCIDRVGEN_DIR/pcidrvgen.ko $MOUNT_DIR/lib/modules/$KERNEL_VERSION/dance/

# pcycle, flash
cp $ROOTFS_PCYCLE_DIR/pcycle $MOUNT_DIR/usr/bin/
cp $ROOTFS_FLASH_DIR/flash $MOUNT_DIR/usr/bin/

chown -R root $MOUNT_DIR
chgrp -R root $MOUNT_DIR
chmod -R 755 $MOUNT_DIR

umount $MOUNT_DIR
