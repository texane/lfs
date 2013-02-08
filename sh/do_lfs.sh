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


# build from sources

function do_build_make_targets {
 do_print 'make '

 makefile_path=$1
 is_read_or_error $makefile_path
 shift 1

 do_exec \
 CROSS_COMPILE=$LFS_CROSS_COMPILE \
 make -f $makefile_path $@
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

 do_build_make_clean $makefile_path $make_args
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

 # save previous path

 previous_path=`pwd`
 cd $LFS_THIS_SOFT_SRC

 makefile_dir=$LFS_THIS_SOFT_SRC
 makefile_path=$makefile_dir/Makefile

 # make clean

 do_build_make_clean_mrproper $makefile_path

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
  ARCH=$LFS_TARGET_ARCH \
  CROSS_COMPILE=$LFS_CROSS_COMPILE \
  CC=$LFS_CROSS_COMPILE\gcc \
  $configure_path --prefix=$LFS_TARGET_INSTALL_DIR
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

 case $LFS_THIS_SOFT_TAR in
  *.tar) x='.tar' ;;
  *.tar.gz) x='.tar.gz' ;;
  *.tgz) x='.tgz' ;;
  *.tar.bz2) x='.tar.bz2' ;;
  *) do_error 'invalid extension' ;;
 esac

 export LFS_THIS_SOFT_SRC=$LFS_SRC_DIR/$LFS_THIS_SOFT_NAME

 if [ -d $LFS_THIS_SOFT_SRC ]; then
  do_print 'already exist'
 else
  case $x in
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

function do_retrieve {
 # require LFS_THIS_SOFT_DIR
 # provide LFS_THIS_SOFT_NAME
 # provide LFS_THIS_SOFT_TAR

 # retrieve tarball

 do_print 'retrieving' $LFS_THIS_SOFT_NAME

 soft_url=$LFS_THIS_SOFT_URL
 do_print 'at' $soft_url

 soft_url_noscheme=${soft_url/*:\/\//}
 soft_base_name=`basename $soft_url_noscheme`
 [ -z "$soft_base_name" ] && do_error 'invalid base name'

 export LFS_THIS_SOFT_TAR=$LFS_TAR_DIR/$soft_base_name

 if [ -e $LFS_THIS_SOFT_TAR ]; then
  do_print 'already exist'
 else
  case $soft_url in
   file://*) do_retrieve_file $soft_url_noscheme $LFS_THIS_SOFT_TAR ;;
   http://*) do_retrieve_http $soft_url $LFS_THIS_SOFT_TAR ;;
   https://*) do_retrieve_https $soft_url $LFS_THIS_SOFT_TAR ;;
   ftp://*) do_retrieve_ftp $soft_url $LFS_THIS_SOFT_TAR ;;
   git://*) do_retrieve_git $soft_url $LFS_THIS_SOFT_TAR ;;
   *) do_error 'scheme not implemented' ;;
  esac
 fi
}


# install a soft

function do_install {
 # require LFS_THIS_SOFT_DIR

 do_print '--'
 do_print 'installing' $LFS_THIS_SOFT_NAME

 do_retrieve
 do_extract
 do_build

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
 export LFS_THIS_SOFT_KBUILD_INSTALL_PATH=$LFS_UNDEF_STRING
 export LFS_THIS_SOFT_KBUILD_INSTALL_MOD_PATH=$LFS_UNDEF_STRING
 export LFS_THIS_SOFT_MAKE_ARGS=$LFS_UNDEF_STRING
 export LFS_THIS_SOFT_IS_ENABLED=0

 . $LFS_THIS_SOFT_DIR/do_conf.sh

 # require LFS_THIS_SOFT_IS_ENABLED
 # optional LFS_THIS_SOFT_DEPS
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
  do_one_soft
 done
}


# install rootfs

function do_rootfs {
 do_foreach_soft
}


# prepare the disk structure

function do_init_disk {
 # NOTE
 # the backing store can be either a file an image or a filesystem.
 # this is chosen by global settings. if the store is either a file
 # or a physical block device, the root partition is mounted on
 # LFS_TARGET_INSTALL_DIR and the boot partition is mounted on
 # $LFS_TARGET_INSTALL_DIR/boot. If the store is the filesystem
 # itself, nothing is done since directories are create by do_prepare
 # the bootloader soft must take care of not installing itself since
 # LFS_DISK_DEV will not be set.

 # TODO
 # if the disk is backed by a file, first create a disk image of the
 # corresponding size. then mount in loop mode.

 # TODO
 # partition the disk

 # TODO
 # mount the directories

 return
}

function do_fini_disk {

 # TODO
 # umount the filesystems

 # TODO
 # umount the block device if required

 return
}


# source board conf and install softs

function do_board {
 # provide LFS_THIS_BOARD_NAME
 export LFS_THIS_BOARD_DIR=$LFS_TOP_DIR/board/$LFS_THIS_BOARD_NAME
 [ ! -d $LFS_THIS_BOARD_DIR ] && do_error 'invalid board name'
 [ ! -e $LFS_THIS_BOARD_DIR/do_conf.sh ] && do_error 'no board conf found'
 . $LFS_THIS_BOARD_DIR/do_conf.sh
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
 [ -e $LFS_SH_DIR/do_user_globals.sh ] && . $LFS_SH_DIR/do_user_globals.sh
 [ -e $LFS_SH_DIR/do_default_globals.sh ] && . $LFS_SH_DIR/do_default_globals.sh
}


# main

# this scripted can be invoked as a standalone tool to
# sequence the install process or sourced for its routines
# and configuration variables during the install process.
# LFS_THIS_BOARD_NAME is used to distinguish both cases.
if [ -z $LFS_THIS_BOARD_NAME ]; then
 [ -z "$1" ] && do_error 'missing board name'
 export LFS_THIS_BOARD_NAME="$1"
 do_globals
 do_board
 do_prepare
 do_init_disk
 do_rootfs
 do_fini_disk
else
 do_globals
 do_board
fi
