#!/usr/bin/env sh

echo installing $BOOT_PART


# format BOOT_PART
echo formating $BOOT_PART

mkfs.vfat $BOOT_PART

MOUNT_DIR=/tmp/bootfs
[ -d $MOUNT_DIR ] || mkdir $MOUNT_DIR
mount $BOOT_PART $MOUNT_DIR


# install grub on BOOT_PART

echo installing grub on device $DEV, partition $BOOT_PART

grub-install --boot-directory=$MOUNT_DIR $DEV
BOOTFS_DIR=/home/lementec/repo/dance/local/bootfs
cp -rf $BOOTFS_DIR/grub/grub.cfg $MOUNT_DIR/grub/grub.cfg


# install linux

echo installing linux in $BOOT_PART

KERNEL_DIR=/home/lementec/repo/dance/local/kernel/linux-$KERNEL_VERSION
cp $KERNEL_DIR/arch/x86/boot/bzImage $MOUNT_DIR/vmlinuz-$KERNEL_VERSION
cp $KERNEL_DIR/.config $MOUNT_DIR/config-$KERNEL_VERSION

umount $MOUNT_DIR
