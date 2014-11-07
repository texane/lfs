#!/bin/ash

. /etc/rc.d/functions
. /etc/dance/profile

echo -n "Remounting root ro: "
mount -o remount,ro,noload,noatime /
check_status
