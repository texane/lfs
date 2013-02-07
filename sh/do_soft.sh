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
 src_dir=$1
 do_print 'building' $src_dir
}


# extract a tarball

function do_extract_tar {
 tar_path=$1
 dest_dir=$LFS_SRC_DIR
 do_exec tar xvf $tar_path -C $dest_dir
}

function do_extract_tar_gz {
 tar_path=$1
 dest_dir=$LFS_SRC_DIR
 do_exec tar xzvf $tar_path -C $dest_dir
}

function do_extract_tar_bz2 {
 bz_path=$1
 do_exec bzip2 -d $bz_path
 tar_path=${bz_path/.tar.bz2/.tar}
 do_extract_tar $tar_path
}

function do_extract {
 tar_path=$1

 case $tar_path in
  *.tar) x='.tar' ;;
  *.tar.gz) x='.tar.gz' ;;
  *.tgz) x='.tgz' ;;
  *.tar.bz2) x='.tar.bz2' ;;
  *) do_error 'invalid tarball extension' ;;
 esac

 src_dir=$LFS_SRC_DIR/`basename ${tar_path/$x/}`
 if [ -d $src_dir ]; then
  do_print 'src already exist'
 elif [ $x = '.tar' ]; then
  do_extract_tar $tar_path
 elif [ $x = '.tar.gz' ]; then
  do_extract_tar_gz $tar_path
 elif [ $x = '.tgz' ]; then
  do_extract_tar_gz $tar_path
 elif [ $x = '.tar.bz2' ]; then
  do_extract_tar_bz2 $tar_path
 fi

 do_build $src_dir
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
 soft_dir=$1

 # retrieve tarball

 do_print 'retrieving' $soft_dir
 is_read_or_error $soft_dir/do_url.sh
 . $soft_dir/do_url.sh
 [ -z "$LFS_RETURN_VALUE" ] && do_error 'invalid url'
 soft_url=$LFS_RETURN_VALUE
 do_print 'at' $soft_url

 soft_url_noscheme=${soft_url/*:\/\//}
 soft_base_name=`basename $soft_url_noscheme`
 [ -z "$soft_base_name" ] && do_error 'invalid base name'

 soft_tar_path=$LFS_TAR_DIR/$soft_base_name

 if [ -e $soft_tar_path ]; then
  do_print 'already exist'
 else
  case $soft_url in
   file://*) do_retrieve_file $soft_url $soft_tar_path ;;
   http://*) do_retrieve_http $soft_url $soft_tar_path ;;
   https://*) do_retrieve_https $soft_url $soft_tar_path ;;
   ftp://*) do_retrieve_ftp $soft_url $soft_tar_path ;;
   git://*) do_retrieve_git $soft_url $soft_tar_path ;;
   *) do_error 'scheme not implemented' ;;
  esac
 fi

 # extract tarball into src
 soft_tar_path=$LFS_TAR_DIR/$soft_base_name
 do_print 'extracting' $soft_tar_path
 do_extract $soft_tar_path
}


# install a soft

function do_install {
 soft_dir=$1
 do_print 'installing' $soft_dir
 do_retrieve $soft_dir
}


# iterate over softs

function do_soft {
 for f in $LFS_TOP_DIR/soft/*; do
  [ -d $f ] || continue
  [ -x $f/do_match.sh ] || continue
  LFS_RETURN_VALUE=1
  . $f/do_match.sh
  [ $LFS_RETURN_VALUE == 0 ] && continue
  do_install $f
 done
}


# source board conf and install softs

function do_board {
 board_name="$1"
 [ -z $board_name ] && do_error 'missing board name'
 board_dir=$LFS_TOP_DIR/board/$board_name
 [ ! -d $board_dir ] && do_error 'invalid board name'
 [ ! -e $board_dir/do_conf.sh ] && do_error 'no board conf found'
 . $board_dir/do_conf.sh
 do_soft
}


# prepare stuffs before installing

function do_prepare {
 for d in $LFS_WORK_DIR $LFS_TAR_DIR $LFS_SRC_DIR $LFS_INSTALL_DIR; do
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
do_globals
do_prepare
do_board $1
