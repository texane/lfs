#!/usr/bin/env bash


# constant

export LFS_UNDEF_STRING='__undef__'


# printing routines

function do_print {
 echo '[ lfs ]' $@
}


# exit on error

function do_error {
 [ -z "$1" ] || do_print '[ error ]' $@
 exit -1
}


# error if a file is not executable

function exist_or_error {
 [ -e $1 ] || do_error $1 'does not exist'
}

function is_read_or_error {
 [ -r $1 ] || do_error $1 'not readable'
}

function is_exec_or_error {
 exist_or_error $1
 [ -x $1 ] || do_error $1 'not executable'
}


# export if empty

function export_if_empty {
 eval [ -z \$${1} ] && export $1=$2
}


# exec and exit on error

function do_exec {
 eval $@
 [ $? == -1 ] && do_error 'failed to execute'
}

function do_exec_sudo {
 echo 'do_exec_sudo' $@

 LFS_RETURN_VALUE=`sudo $@`
 [ $? == -1 ] && do_error 'failed to execute'
}


# build from sources

function do_build_make_targets {
 do_print 'make '

 makefile_path=$1
 is_read_or_error $makefile_path
 shift 1

 if [ $LFS_THIS_SOFT_IS_CROSS_COMPILED == 1 ]; then
  do_exec \
  CROSS_COMPILE=$LFS_CROSS_COMPILE \
  make -f $makefile_path $@
 else
  do_exec make -f $makefile_path $@
 fi
}

function do_build_make_clean {
 do_build_make_targets $@ clean
}

function do_build_make_clean_mrproper {
 do_build_make_clean $@
 do_build_make_targets $@ mrproper
}

function do_build_make_install {
 do_build_make_targets $@ install
}

function do_build_make_modules_install {
 do_build_make_targets $@ modules_install
}

function do_build_make_notarget {
 do_build_make_targets $@ ''
}

function do_build_make {
 # require globals
 # require LFS_THIS_SOFT_BUILD
 # require LFS_THIS_BOARD_DIR
 # require LFS_THIS_SOFT_SRC

 do_print 'do_build_make'

 previous_path=`pwd`
 cd $LFS_THIS_SOFT_SRC

 makefile_dir=$LFS_THIS_SOFT_SRC
 makefile_path=$makefile_dir/Makefile

 make_args=''
 if [ "$LFS_THIS_SOFT_MAKE_ARGS" != $LFS_UNDEF_STRING ]; then
  make_args=$LFS_THIS_SOFT_MAKE_ARGS
 fi

 # TO_UNCOMMENT
 # do_build_make_clean $makefile_path $make_args
 do_build_make_notarget $makefile_path $make_args
 do_build_make_install $makefile_path $make_args

 cd $previous_path
}

function do_sed_keyval {
 file_path=$1
 key=$2
 val=${3//\//\\\/}
 do_exec sed -i -e "'s/^\($key\)=\"\(.*\)\"$/\1=\"$val\"/g'" $file_path
}

function do_build_kbuild {
 # kbuild documentation in Documentation/kbuild/kbuild.txt
 # require globals
 # require LFS_THIS_SOFT_BUILD
 # require LFS_THIS_BOARD_DIR
 # require LFS_THIS_SOFT_SRC
 # require LFS_THIS_SOFT_NAME
 # require LFS_THIS_SOFT_VERS

 do_print 'do_build_kbuild'

 # TODO
 if [ $LFS_THIS_SOFT_IS_CROSS_COMPILED == 0 ]; then
  do_error 'host compilation not supported'
 fi

 # save previous path

 previous_path=`pwd`
 cd $LFS_THIS_SOFT_SRC

 makefile_dir=$LFS_THIS_SOFT_SRC
 makefile_path=$makefile_dir/Makefile

 # make clean
 # TO_UNCOMMENT
 # do_build_make_clean_mrproper $makefile_path

 # read a .config file

 dotconfig_path=$LFS_THIS_BOARD_DIR/$LFS_THIS_SOFT_NAME-$LFS_THIS_SOFT_VERS.config
 if [ -r $dotconfig_path ]; then
  do_print 'dotconfig' $config_path
  cp $dotconfig_path $makefile_dir/.config

  # sed known variables in
  dotconfig_path=$makefile_dir/.config
  do_sed_keyval $dotconfig_path CONFIG_CROSS_COMPILER_PREFIX $LFS_CROSS_COMPILE
  do_sed_keyval $dotconfig_path CONFIG_CROSS_COMPILE $LFS_CROSS_COMPILE
  do_sed_keyval $dotconfig_path CONFIG_PREFIX $LFS_TARGET_INSTALL_DIR
 fi

 export ARCH=$LFS_TARGET_ARCH

 if [ $LFS_THIS_SOFT_KBUILD_INSTALL_PATH != $LFS_UNDEF_STRING ]; then
  export INSTALL_PATH=$LFS_THIS_SOFT_KBUILD_INSTALL_PATH
 fi

 if [ $LFS_THIS_SOFT_KBUILD_INSTALL_MOD_PATH != $LFS_UNDEF_STRING ]; then
  export INSTALL_MOD_PATH=$LFS_THIS_SOFT_KBUILD_INSTALL_MOD_PATH
 fi

 # make
 do_build_make_notarget $makefile_path

 # make install
 do_build_make_install $makefile_path

 # make modules_install
 if [ $LFS_THIS_SOFT_KBUILD_INSTALL_MOD_PATH != $LFS_UNDEF_STRING ]; then
  do_build_make_modules_install $makefile_path
 fi

 unset ARCH
 unset INSTALL_PATH
 unset INSTALL_MOD_PATH
 
 # restore previous path
 cd $previous_path

}

function do_build_autotools {
 # make clean
 # bootstrap
 # configure
 # make install

 # require globals
 # require LFS_THIS_SOFT_BUILD
 # require LFS_THIS_BOARD_DIR
 # require LFS_THIS_SOFT_SRC
 # require LFS_THIS_SOFT_NAME
 # require LFS_THIS_SOFT_INSTALL

 do_print 'do_build_autotools'

 # save previous path

 previous_path=`pwd`
 cd $LFS_THIS_SOFT_SRC

 configure_dir=$LFS_THIS_SOFT_SRC
 configure_path=$configure_dir/configure
 makefile_dir=$LFS_THIS_SOFT_SRC
 makefile_path=$makefile_dir/Makefile

 # make clean

 if [ -r $makefile_path ]; then
  do_build_make_clean $makefile_path
 fi

 # bootstrap

 if [ -x $LFS_THIS_SOFT_SRC/bootstrap ]; then
  do_print 'bootstrap'
  $LFS_THIS_SOFT_SRC/bootstrap
  is_exec_or_error $configure_path
 fi

 # configure

 if [ -x $configure_path ]; then
  do_print 'configure'

  if [ $LFS_THIS_SOFT_IS_CROSS_COMPILED == 1 ]; then
   do_exec \
   ARCH=$LFS_TARGET_ARCH \
   CROSS_COMPILE=$LFS_CROSS_COMPILE \
   CC=$LFS_CROSS_COMPILE\gcc \
   $configure_path --prefix=$LFS_TARGET_INSTALL_DIR
  else
   do_exec $configure_path --prefix=$LFS_HOST_INSTALL_DIR
  fi
 fi

 # make install

 do_build_make_install $makefile_path

 # restore previous path

 cd $previous_path

}

function do_build_byhand {

 # require globals
 # require LFS_THIS_SOFT_BUILD
 # require LFS_THIS_BOARD_DIR
 # require LFS_THIS_SOFT_NAME_VERS

 is_exec_or_error $LFS_THIS_SOFT_DIR/do_build_byhand.sh
 do_exec $LFS_THIS_SOFT_DIR/do_build_byhand.sh
}

function do_build {
 # require globals
 # require LFS_THIS_SOFT_SRC
 # require LFS_THIS_SOFT_NAME
 # provide LFS_THIS_SOFT_BUILD

 export LFS_THIS_SOFT_BUILD=$LFS_BUILD_DIR/$LFS_THIS_SOFT_NAME

 do_print 'building' $LFS_THIS_SOFT_NAME

 if [ -d $LFS_THIS_SOFT_BUILD ]; then
  do_print 'already exist'
  return 0
 fi

 do_exec mkdir $LFS_THIS_SOFT_BUILD

 LFS_DO_BUILD_BYHAND=0
 case $LFS_THIS_SOFT_BUILD_METHOD in
  $LFS_UNDEF_STRING) do_print 'nothing to do' ;;
  make) do_build_make ;;
  autotools) do_build_autotools ;;
  kbuild) do_build_kbuild ;;
  byhand) do_build_byhand ;;
  *) do_error 'invalid build method' ;;
 esac
}


# extract a tarball

function do_extract_tar_with_opt {
 tar_path=$1
 dest_dir=$2
 tar_opt="$3"
 do_exec mkdir $dest_dir
 do_exec tar $tar_opt\xvf $tar_path --strip 1 -C $dest_dir
}

function do_extract_tar {
 do_extract_tar_with_opt $1 $2 ''
}

function do_extract_tar_gz {
 do_extract_tar_with_opt $1 $2 'z'
}

function do_extract_tar_bz2 {
 do_extract_tar_with_opt $1 $2 'j'
}

function do_extract {
 # require globals
 # require LFS_THIS_SOFT_TAR
 # provide LFS_THIS_SOFT_SRC
 # provide LFS_THIS_SOFT_NAME

 do_print 'extracting' $LFS_THIS_SOFT_NAME

 if [ $LFS_THIS_SOFT_URL == $LFS_UNDEF_STRING ]; then
  do_print 'nothing to extract'
  return
 fi

 export LFS_THIS_SOFT_SRC=$LFS_SRC_DIR/$LFS_THIS_SOFT_NAME

 if [ -d $LFS_THIS_SOFT_SRC ]; then
  do_print 'already exist'
 else
  case $LFS_THIS_SOFT_TAR_EXT in
   .tar) do_extract_tar $LFS_THIS_SOFT_TAR $LFS_THIS_SOFT_SRC ;;
   .tar.gz) do_extract_tar_gz $LFS_THIS_SOFT_TAR $LFS_THIS_SOFT_SRC ;;
   .tgz) do_extract_tar_gz $LFS_THIS_SOFT_TAR $LFS_THIS_SOFT_SRC ;;
   .tar.bz2) do_extract_tar_bz2 $LFS_THIS_SOFT_TAR $LFS_THIS_SOFT_SRC ;;
  esac
 fi
}


# retrieve a soft tarball

function do_retrieve_file {
 soft_url=$1
 soft_tar_path=$2
 do_exec cp $soft_url $soft_tar_path
}

function do_retrieve_http {
 soft_url=$1
 soft_tar_path=$2
 # must be removed on failure
 wget $soft_url -O $soft_tar_path
 if [ ! $? == 0 ]; then
  rm $soft_tar_path
  do_error 'download error'
 fi
}

function do_retrieve_https {
 do_retrieve_http $@
}

function do_retrieve_ftp {
 do_retrieve_http $@
}

function do_retrieve_git {
 do_error 'git scheme not implemented'
}

function do_retrieve_svn {
 # remove leading svn://
 soft_url=${1:6}
 soft_tar_path=$2

 # remove trailing extension
 tmp_path=${soft_tar_path::-${#LFS_THIS_SOFT_TAR_EXT}}
 
 do_exec svn export $soft_url $tmp_path
 pushd .
 cd `dirname $tmp_path`
 do_exec tar czvf $soft_tar_path `basename $tmp_path` --exclude='*/.svn'
 popd
 do_exec rm -rf $tmp_path
}

function do_retrieve {
 # require LFS_THIS_SOFT_DIR
 # provide LFS_THIS_SOFT_NAME
 # provide LFS_THIS_SOFT_TAR
 # provide LFS_THIS_SOFT_TAR_EXT

 # retrieve tarball

 do_print 'retrieving' $LFS_THIS_SOFT_NAME

 if [ $LFS_THIS_SOFT_URL == $LFS_UNDEF_STRING ]; then
  do_print 'nothing to retrieve'
  return
 fi

 soft_url=$LFS_THIS_SOFT_URL
 do_print 'at' $soft_url
 soft_url_noscheme=${soft_url/*:\/\//}

 # guess the tarball path according to url extension, default to .tar.gz
 case $LFS_THIS_SOFT_URL in
  *.tar) x='.tar' ;;
  *.tar.gz) x='.tar.gz' ;;
  *.tgz) x='.tgz' ;;
  *.tar.bz2) x='.tar.bz2' ;;
  *) x='.tar.gz' ;;
 esac
 export LFS_THIS_SOFT_TAR_EXT=$x
 export LFS_THIS_SOFT_TAR=$LFS_TAR_DIR/$LFS_THIS_SOFT_NAME$x

 if [ -e $LFS_THIS_SOFT_TAR ]; then
  do_print 'already exist'
 else
  case $soft_url in
   file://*) do_retrieve_file $soft_url_noscheme $LFS_THIS_SOFT_TAR ;;
   http://*) do_retrieve_http $soft_url $LFS_THIS_SOFT_TAR ;;
   https://*) do_retrieve_https $soft_url $LFS_THIS_SOFT_TAR ;;
   ftp://*) do_retrieve_ftp $soft_url $LFS_THIS_SOFT_TAR ;;
   git://*) do_retrieve_git $soft_url $LFS_THIS_SOFT_TAR ;;
   svn://*) do_retrieve_svn $soft_url $LFS_THIS_SOFT_TAR ;;
   *) do_error 'scheme not implemented' ;;
  esac
 fi
}


# post build actions

function do_post_build {
 [ -x $LFS_THIS_SOFT_DIR/do_post_build.sh ] || return
 do_print 'do_post_build'
 do_exec $LFS_THIS_SOFT_DIR/do_post_build.sh
}


# patch a soft

function do_patch {
 # optionnal LFS_THIS_SOFT_PATCHES

 previous_path=`pwd`
 cd $LFS_THIS_SOFT_SRC

 for p in $LFS_THIS_SOFT_PATCHES; do
  # fixme: redirection not yet supported by do_exec
  patch -N -p1 < $p
  [ $? == -1 ] && do_error 'failed to execute'
 done

 cd $previous_path
}


# install a soft

function do_install {
 # require LFS_THIS_SOFT_DIR

 do_print '--'
 do_print 'installing' $LFS_THIS_SOFT_NAME

 do_retrieve
 do_extract
 do_patch
 do_build
 do_post_build

}


# iterate over softs

function do_one_soft {
 # require globals
 # require LFS_THIS_SOFT_NAME

 export LFS_THIS_SOFT_DIR=$LFS_TOP_DIR/soft/$LFS_THIS_SOFT_NAME

 [ -d $LFS_THIS_SOFT_DIR ] || return 0

 [ -r $LFS_THIS_SOFT_DIR/do_conf.sh ] || return 0

 # default values
 export LFS_THIS_SOFT_VERS=''
 export LFS_THIS_SOFT_DEPS=''
 export LFS_THIS_SOFT_PATCHES=''
 export LFS_THIS_SOFT_BUILD_METHOD=$LFS_UNDEF_STRING
 export LFS_THIS_SOFT_URL=$LFS_UNDEF_STRING
 export LFS_THIS_SOFT_KBUILD_INSTALL_PATH=$LFS_UNDEF_STRING
 export LFS_THIS_SOFT_KBUILD_INSTALL_MOD_PATH=$LFS_UNDEF_STRING
 export LFS_THIS_SOFT_MAKE_ARGS=$LFS_UNDEF_STRING
 export LFS_THIS_SOFT_IS_ENABLED=0
 export LFS_THIS_SOFT_IS_CROSS_COMPILED=1

 . $LFS_THIS_SOFT_DIR/do_conf.sh

 # require LFS_THIS_SOFT_IS_ENABLED
 # optional LFS_THIS_SOFT_IS_CROSS_COMPILED
 # optional LFS_THIS_SOFT_DEPS
 # optional LFS_THIS_SOFT_PATCHES
 # optional LFS_THIS_SOFT_VERS
 # require LFS_THIS_SOFT_URL
 # require LFS_THIS_SOFT_BUILD_METHOD
 # optional LFS_THIS_SOFT_KBUILD_INSTALL_PATH
 # optional LFS_THIS_SOFT_KBUILD_INSTALL_MOD_PATH
 # optional LFS_THIS_SOFT_MAKE_ARGS

 [ $LFS_THIS_SOFT_IS_ENABLED  == 0 ] && return 0

 # dependencies
 for d in $LFS_THIS_SOFT_DEPS; do
  $LFS_TOP_DIR/sh/do_install_soft.sh $d
 done

 do_install
}

function do_foreach_soft {
 # require globals

 for f in $LFS_TOP_DIR/soft/*; do
  export LFS_THIS_SOFT_NAME=`basename $f`
  # sdk must be installed at the end
  if [ $LFS_THIS_SOFT_NAME != 'sdk' ]; then
   do_one_soft
  fi
 done
}


# install rootfs

function do_rootfs {
 # build the toolchain first
 if [ -d $LFS_TOP_DIR/soft/crosstool-ng ]; then
  export LFS_THIS_SOFT_NAME=crosstool-ng
  do_one_soft
 fi

 do_foreach_soft

 # build the sdk
 if [ -d $LFS_TOP_DIR/soft/sdk ]; then
  export LFS_THIS_SOFT_NAME=sdk
  do_one_soft
 fi
}


# create a disk image

function do_create_disk_images {
 # require LFS_DISK_IMAGE
 # require LFS_DISK_BOOT_IMAGE
 # require LFS_DISK_BOOT_SIZE
 # require LFS_DISK_ROOT_IMAGE
 # require LFS_DISK_ROOT_SIZE

 do_print 'create_disk_images'

 # convert to sector
 sector_size=512
 mb_size=$((1024 * 1024))
 mul_size=$(($mb_size / $sector_size))
 mbr_size=1
 empty_size=$(($LFS_DISK_EMPTY_SIZE * $mul_size))
 boot_size=$(($LFS_DISK_BOOT_SIZE * $mul_size))
 root_size=$(($LFS_DISK_ROOT_SIZE * $mul_size))
 disk_size=$(($mbr_size + $empty_size + $boot_size + $root_size))

 do_print 'dd' $LFS_DISK_IMAGE
 # TO_REMOVE, existing condition
 [ -e $LFS_DISK_IMAGE ] || \
 do_exec dd if=/dev/zero of=$LFS_DISK_IMAGE bs=$sector_size count=$disk_size

 do_print 'dd' $LFS_DISK_BOOT_IMAGE
 # TO_REMOVE, existing condition
 [ -e $LFS_DISK_BOOT_IMAGE ] || \
 do_exec dd if=/dev/zero of=$LFS_DISK_BOOT_IMAGE bs=1M count=$LFS_DISK_BOOT_SIZE

 do_print 'dd' $LFS_DISK_ROOT_IMAGE
 # TO_REMOVE, existing condition
 [ -e $LFS_DISK_ROOT_IMAGE ] || \
 do_exec dd if=/dev/zero of=$LFS_DISK_ROOT_IMAGE bs=1M count=$LFS_DISK_ROOT_SIZE
}

function do_merge_disk_images {
 # require LFS_DISK_IMAGE
 # require LFS_DISK_EMPTY_SIZE
 # require LFS_DISK_BOOT_IMAGE
 # require LFS_DISK_BOOT_SIZE
 # require LFS_DISK_ROOT_IMAGE

 do_print 'merge_disk_images'

 # convert to sector
 sector_size=512
 mb_size=$((1024 * 1024))
 mul_size=$(($mb_size / $sector_size))
 mbr_size=1
 empty_size=$(($LFS_DISK_EMPTY_SIZE * $mul_size))
 boot_size=$(($LFS_DISK_BOOT_SIZE * $mul_size))
 boot_off=$(($mbr_size + $empty_size))
 root_off=$(($boot_off + $boot_size))

 do_exec dd if=$LFS_DISK_BOOT_IMAGE of=$LFS_DISK_IMAGE bs=$sector_size seek=$boot_off
 do_exec dd if=$LFS_DISK_ROOT_IMAGE of=$LFS_DISK_IMAGE bs=$sector_size seek=$root_off
}

# ask for disk setup

function do_ask_disk_setup {
 do_print '--'
 do_print 'disk device summmary'
 do_print "LFS_DISK_DEV: $LFS_DISK_DEV"
 do_print "LFS_DISK_ROOT_DEV: $LFS_DISK_ROOT_DEV ($LFS_DISK_ROOT_SIZE MB)"
 do_print "LFS_DISK_BOOT_DEV: $LFS_DISK_BOOT_DEV ($LFS_DISK_BOOT_SIZE MB)"
 do_print 'the devices contents will get lost'
 read -p 'press ENTER to continue, kill to abort (and undo manually)'
}


# partition the disk

function do_part_disk {
 do_print 'part_disk' $LFS_DISK_DEV

 tmp_path='/tmp/__lfs__'
 [ -e $tmp_path ] && do_exec rm $tmp_path

 # convert to sectors
 sector_size=512
 mb_size=$((1024 * 1024))
 mul_size=$(($mb_size / $sector_size))
 empty_size=$(($LFS_DISK_EMPTY_SIZE * $mul_size))
 boot_size=$(($LFS_DISK_BOOT_SIZE * $mul_size))

 first_sector='1'
 if [ $empty_size != 0 ]; then
  echo "1,$empty_size,0," >> $tmp_path
  first_sector=''
 fi
 echo "$first_sector,$boot_size,c,*" >> $tmp_path
 echo ",,83," >> $tmp_path

 # FIXME: inlined sudo, dunno how to pass args
 sudo sh -c "sfdisk --no-reread -f -uS $LFS_DISK_DEV < $tmp_path"

 do_exec rm $tmp_path
}


# format the disk
function do_format_disk {
 do_exec_sudo mkfs.vfat $LFS_DISK_BOOT_DEV

 case $LFS_DISK_ROOT_FS in
  ext2)
   do_exec_sudo mkfs.ext2 $LFS_DISK_ROOT_DEV
   do_exec_sudo tune2fs -c -1 $LFS_DISK_ROOT_DEV
   ;;
  ext3)
   do_exec_sudo mkfs.ext3 $LFS_DISK_ROOT_DEV
   ;;
  *)
   do_error 'invalid root filesystem type'
   ;;
 esac
}


# mount the disk

function do_mount_disk {
 # require LFS_DISK_BOOT_DEV
 # require LFS_DISK_BOOT_DEV

 do_print 'mount_disk'

 do_print 'mounting rootfs on' $LFS_DISK_ROOT_DEV
 do_exec_sudo mount $LFS_DISK_ROOT_DEV $LFS_TARGET_INSTALL_DIR
 do_exec_sudo chown -R $USER $LFS_TARGET_INSTALL_DIR

 do_print 'mounting bootfs on' $LFS_DISK_BOOT_DEV

 if [ ! -d $LFS_TARGET_INSTALL_DIR/boot ]; then
  do_exec mkdir $LFS_TARGET_INSTALL_DIR/boot
  do_exec_sudo chown $USER $LFS_TARGET_INSTALL_DIR/boot
 fi

 # umask option needed since fat does not suppport rights
 do_exec_sudo mount -oumask=000 $LFS_DISK_BOOT_DEV $LFS_TARGET_INSTALL_DIR/boot
}

function do_umount_disk {
 do_print 'umount_disk'

 do_exec_sudo umount $LFS_TARGET_INSTALL_DIR/boot
 do_exec_sudo chmod 755 $LFS_TARGET_INSTALL_DIR/boot
 do_exec_sudo chown -R root $LFS_TARGET_INSTALL_DIR
 do_exec_sudo umount $LFS_TARGET_INSTALL_DIR
}


# prepare the disk structure

function do_init_disk {
 # optional LFS_DISK_DEV
 # optional LFS_DISK_IMAGE
 # optional LFS_DISK_BOOT_SIZE
 # optional LFS_DISK_ROOT_SIZE
 # provide LFS_DISK_DEV
 # provide LFS_DISK_BOOT_DEV
 # provide LFS_DISK_ROOT_DEV
 # provide LFS_DISK_BOOT_IMAGE
 # provide LFS_DISK_ROOT_IMAGE

 do_print 'init_disk'

 # default variables
 export LFS_DISK_BOOT_DEV=''
 export LFS_DISK_ROOT_DEV=''

 # NOTE
 # the backing store can be either a file an image or a filesystem.
 # this is chosen by global settings.
 # if the store is a file, 2 files are first created for boot and
 # root partitions, since losetup does not accept a size when binding
 # a block device to a file. they are merged by do_disk_fini.
 # if the store is a file or a physical block device, the root partition
 # is mounted on LFS_TARGET_INSTALL_DIR and the boot partition is mounted
 # on $LFS_TARGET_INSTALL_DIR/boot.
 # if the store is the filesystem itself, nothing is done since directories
 # are created by do_prepare. the bootloader soft must take care of not
 # installing itself by looking at LFS_DISK_DEV being empty.

 if [ "$LFS_DISK_DEV" == '' ]; then
  if [ "$LFS_DISK_IMAGE" == '' ]; then
   return
  fi
 fi

 do_part_format=1

 # create a disk image
 if [ $LFS_DISK_IMAGE != '' ]; then

  LFS_DISK_ROOT_IMAGE=$LFS_DISK_IMAGE\_root
  LFS_DISK_BOOT_IMAGE=$LFS_DISK_IMAGE\_boot
  
  if [ ! -e $LFS_DISK_IMAGE ]; then
   do_create_disk_images
  else
   do_part_format=0
  fi

  # find 3 loop devices
  do_exec_sudo losetup -s -f $LFS_DISK_IMAGE
  LFS_DISK_DEV=$LFS_RETURN_VALUE
  do_exec_sudo losetup -s -f $LFS_DISK_BOOT_IMAGE
  LFS_DISK_BOOT_DEV=$LFS_RETURN_VALUE
  do_exec_sudo losetup -s -f $LFS_DISK_ROOT_IMAGE
  LFS_DISK_ROOT_DEV=$LFS_RETURN_VALUE

 else
  i=1
  [ "$LFS_DISK_EMPTY_SIZE" != '0' ] && i=2
  LFS_DISK_BOOT_DEV=$LFS_DISK_DEV$(($i + 0))
  LFS_DISK_ROOT_DEV=$LFS_DISK_DEV$(($i + 1))
 fi

 if [ $do_part_format == 1 ]; then
  # ask the user if setup is correct
  do_ask_disk_setup
  # partition the disk
  do_part_disk
  # format the disk
  do_format_disk
 fi

 # mount the disk
 do_mount_disk
}

function do_fini_disk {

 do_print 'fini_disk'

 # filesystem is used, nothing to do
 [ "$LFS_DISK_DEV" == '' ] && return

 # umount disk filesystems
 do_umount_disk

 # unlosetup, merge disk images
 if [ "$LFS_DISK_IMAGE" != '' ]; then
  do_exec_sudo losetup -d $LFS_DISK_DEV
  do_exec_sudo losetup -d $LFS_DISK_ROOT_DEV
  do_exec_sudo losetup -d $LFS_DISK_BOOT_DEV
  do_merge_disk_images
 fi
}


# source board conf and install softs

function do_board {
 # provide LFS_THIS_BOARD_NAME
 export LFS_THIS_BOARD_DIR=$LFS_TOP_DIR/board/$LFS_THIS_BOARD_NAME
 [ ! -d $LFS_THIS_BOARD_DIR ] && do_error 'invalid board name'
 [ ! -e $LFS_THIS_BOARD_DIR/do_conf.sh ] && do_error 'no board conf found'
 . $LFS_THIS_BOARD_DIR/do_conf.sh
}


# handle post install environment specific stuffs

function do_post_rootfs {
 do_print 'do_post_rootfs'

 if [ "$LFS_THIS_ENV_NAME" != '' ]; then
  do_print 'do_env' $LFS_THIS_ENV_NAME
  env_dir=$LFS_TOP_DIR/env/$LFS_THIS_ENV_NAME
  [ -d $env_dir ] || do_error 'invalid env name'
  if [ -x $env_dir/do_post_rootfs.sh ]; then
   do_exec $env_dir/do_post_rootfs.sh
  else
   do_print 'no post rootfs script'
  fi
 fi
}


# prepare stuffs before installing

function do_prepare {
 for d in \
  $LFS_WORK_DIR \
  $LFS_TAR_DIR \
  $LFS_SRC_DIR \
  $LFS_TARGET_INSTALL_DIR \
  $LFS_HOST_INSTALL_DIR \
  $LFS_BUILD_DIR; do
  [ -d $d ] || do_exec mkdir $d
 done
}


# source globals

function do_globals {
 [ -z $LFS_TOP_DIR ] && export LFS_TOP_DIR=`pwd`
 export LFS_SH_DIR=$LFS_TOP_DIR/sh
 [ -e $LFS_SH_DIR/do_default_globals.sh ] && . $LFS_SH_DIR/do_default_globals.sh
 [ -e $LFS_SH_DIR/do_user_globals.sh ] && . $LFS_SH_DIR/do_user_globals.sh
}


# check for required software

function do_required_soft {
 saved_path=$PATH
 PATH=$PATH:/sbin:/usr/sbin:/usr/local/sbin
 for s in \
  'mkfs.vfat' 'tune2fs' 'mke2fs' 'sfdisk' 'losetup' 'sudo' \
  'sed' 'wget' 'bash' 'libtool' 'autoconf' 'autoconf' 'make' \
  'flex' 'bison' 'gawk' 'bzip2' 'tar' 'bash' 'gcc' 'dd' ;
 do
  w=`which $s`
  if [ "$w" == '' ]; then
   do_error 'missing required software:' $s
  fi
 done
 PATH=$saved_path
}


# main

if [ "$LFS_IS_SOURCED" == '' ]; then
 # standalone mode
 [ -z "$LFS_THIS_BOARD_NAME" ] && do_error 'missing LFS_THIS_BOARD_NAME'
 do_required_soft
 do_globals
 do_board
 do_prepare
 do_init_disk
 do_rootfs
 do_post_rootfs
 do_fini_disk
else
 # sourced mode
 do_globals
 do_board
fi
