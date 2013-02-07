# set LFS_RETURN_VALUE to 1 if the software must be
# installed. in this example, the version variable
# is used. execute in the main script context
[ ! -z $LFS_BUSYBOX_VERS ] && LFS_RETURN_VALUE=1
