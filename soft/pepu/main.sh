#!/usr/bin/env bash

TMP_DIR=`pwd`/tmp

export LFS_THIS_SOFT_NAME=pepu

export LFS_TARGET_INSTALL_DIR=$TMP_DIR/target_install
export LFS_TAR_DIR=$TMP_DIR/tar
export LFS_SRC_DIR=$TMP_DIR/src
export LFS_LINUX_VERS=3.10

export LFS_THIS_SOFT_TAR=$LFS_TAR_DIR/pepu.tar.gz
export LFS_THIS_SOFT_TAR_EXT=.tar.gz
export LFS_THIS_BOARD_NAME=seco_imx6

export LFS_THIS_SOFT_SRC=$LFS_SRC_DIR/pepu

mkdir -p $LFS_TARGET_INSTALL_DIR
mkdir -p $LFS_TAR_DIR
mkdir -p $LFS_SRC_DIR


# extract a tarball

function do_extract_tar_with_opt {
 tar_path=$1
 dest_dir=$2
 tar_opt="$3"
 mkdir $dest_dir
 tar $tar_opt\xvf $tar_path --strip 1 -C $dest_dir
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

. ./do_conf.sh
./do_retrieve_byhand.sh
do_extract
./do_build_byhand.sh
./do_post_build.sh
