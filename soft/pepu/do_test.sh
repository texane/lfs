#!/usr/bin/env bash

# passed from command line
export LFS_THIS_BOARD_NAME=seco_imx6
export LFS_THIS_ENV_NAME=comex004
export LFS_THIS_APP_NAME=pepu

# globals
export LFS_TOP_DIR=`pwd`/../..
export LFS_WORK_DIR=`pwd`/tmp

export LFS_IS_SOURCED=yes
. $LFS_TOP_DIR/sh/do_lfs.sh

do_prepare

export LFS_THIS_SOFT_NAME=pepu
do_one_soft
