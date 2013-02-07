#!/usr/bin/env sh

# install grub on BOOT_PART

echo installing $BOOT_PART

KERNEL_DIR=/home/texane/repo/dance/local/kernel/linux-3.6.11
BOOTFS_DIR=/home/texane/repo/rpi/minimal_linux/bootfs

MOUNT_DIR=/tmp/bootfs
[ -d $MOUNT_DIR ] || mkdir $MOUNT_DIR
mount $BOOT_PART $MOUNT_DIR
cp $BOOTFS_DIR/bootcode.bin $MOUNT_DIR/
cp $BOOTFS_DIR/cmdline.txt $MOUNT_DIR/
cp $BOOTFS_DIR/config.txt $MOUNT_DIR/
cp $BOOTFS_DIR/fixup_cd.dat $MOUNT_DIR/
cp $BOOTFS_DIR/fixup.dat $MOUNT_DIR/
cp $BOOTFS_DIR/start_cd.elf $MOUNT_DIR/
cp $BOOTFS_DIR/start.elf $MOUNT_DIR/
cp $KERNEL_DIR/arch/arm/boot/uImage $MOUNT_DIR/kernel.img
umount $MOUNT_DIR
