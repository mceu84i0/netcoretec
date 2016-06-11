#!/bin/sh
#WAN=eth1
WAN=$2

if [ $1 = 'connect' ]; then
     	ENABLE_CONNECT=1
	echo "warning: should not reach here!!!"
else
     	ENABLE_CONNECT=0
fi

multi_ppp $WAN &
