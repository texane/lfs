#!/usr/bin/env bash


# printing routine

function do_print {
 echo '[ lfs ]' $*
}


# exit on error

function do_error {
 [ -z "$1" ] || do_print $*
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
 $*
 [ $? == -1 ] && do_error 'failed to execute'
}


# build from sources

function do_build {
 # assume globals
 # assume LFS_THIS_SOFT_SRC

 do_print 'building' $LFS_THIS_SOFT_SRC
}


# extract a tarball

function do_extract_tar_with_opt {
 tar_path=$1
 dest_dir=$2
 tar_opt="$3"
 do_exec tar $tar_opt\xvf $tar_path -C $dest_dir
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
 # assume globals
 # assume LFS_THIS_SOFT_TAR
 # provide LFS_THIS_SOFT_SRC

 do_print 'extracting' $LFS_THIS_SOFT_TAR

 case $LFS_THIS_SOFT_TAR in
  *.tar) x='.tar' ;;
  *.tar.gz) x='.tar.gz' ;;
  *.tgz) x='.tgz' ;;
  *.tar.bz2) x='.tar.bz2' ;;
  *) do_error 'invalid tarball extension' ;;
 esac

 export LFS_THIS_SOFT_SRC=$LFS_SRC_DIR/`basename ${LFS_THIS_SOFT_TAR/$x/}`
 if [ -d $LFS_THIS_SOFT_SRC ]; then
  do_print 'src already exist'
 elif [ $x = '.tar' ]; then
  do_extract_tar $LFS_THIS_SOFT_TAR $LFS_SRC_DIR
 elif [ $x = '.tar.gz' ]; then
  do_extract_tar_gz $LFS_THIS_SOFT_TAR $LFS_SRC_DIR
 elif [ $x = '.tgz' ]; then
  do_extract_tar_gz $LFS_THIS_SOFT_TAR $LFS_SRC_DIR
 elif [ $x = '.tar.bz2' ]; then
  do_extract_tar_bz2 $LFS_THIS_SOFT_TAR $LFS_SRC_DIR
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
 do_retrieve_http $*
}

function do_retrieve_ftp {
 do_retrieve_http $*
}

function do_retrieve_git {
 do_error 'git scheme not implemented'
}

function do_retrieve {
 # assume LFS_THIS_SOFT_DIR
 # provide LFS_THIS_SOFT_NAME
 # provide LFS_THIS_SOFT_TAR

 # retrieve tarball

 do_print 'retrieving' $LFS_THIS_SOFT_DIR
 is_read_or_error $LFS_THIS_SOFT_DIR/do_url.sh
 . $LFS_THIS_SOFT_DIR/do_url.sh
 [ -z "$LFS_RETURN_VALUE" ] && do_error 'invalid url'
 soft_url=$LFS_RETURN_VALUE
 do_print 'at' $soft_url

 soft_url_noscheme=${soft_url/*:\/\//}
 soft_base_name=`basename $soft_url_noscheme`
 [ -z "$soft_base_name" ] && do_error 'invalid base name'

 export LFS_THIS_SOFT_TAR=$LFS_TAR_DIR/$soft_base_name

 if [ -e $LFS_THIS_SOFT_TAR ]; then
  do_print 'already exist'
 else
  case $soft_url in
   file://*) do_retrieve_file $soft_url $LFS_THIS_SOFT_TAR ;;
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
 # provide LFS_THIS_SOFT_DIR

 do_print 'installing' $LFS_THIS_SOFT_DIR

 do_retrieve
 do_extract
 do_build

}


# iterate over softs

function do_soft {
 for f in $LFS_TOP_DIR/soft/*; do
  [ -d $f ] || continue
  [ -x $f/do_match.sh ] || continue
  LFS_RETURN_VALUE=1
  . $f/do_match.sh
  [ $LFS_RETURN_VALUE == 0 ] && continue
  export LFS_THIS_SOFT_DIR=$f
  do_install
 done
}


# source board conf and install softs

function do_board {
 # provide LFS_THIS_BOARD_NAME
 export LFS_THIS_BOARD_DIR=$LFS_TOP_DIR/board/$LFS_THIS_BOARD_NAME
 [ ! -d $LFS_THIS_BOARD_DIR ] && do_error 'invalid board name'
 [ ! -e $LFS_THIS_BOARD_DIR/do_conf.sh ] && do_error 'no board conf found'
 . $LFS_THIS_BOARD_DIR/do_conf.sh
 do_soft
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

[ -z "$1" ] && do_error 'missing board name'
export LFS_THIS_BOARD_NAME="$1"

do_globals
do_prepare
do_board
