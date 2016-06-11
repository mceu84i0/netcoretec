#!/bin/sh
#WAN=eth1
WAN=$1

if [ $1 = 'connect' ]; then
	ENABLE_CONNECT=1
	WAN=$2
	echo "warning: should not reach here!!!"
else
	ENABLE_CONNECT=0
	WAN=$1
fi

multi_ppp $WAN &
