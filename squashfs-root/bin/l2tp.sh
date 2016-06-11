#!/bin/sh
WAN=$1

eval `flash get L2TP_CONNECTION_TYPE`
if [ $1 = 'connect' ]; then
	ENABLE_CONNECT=1
	WAN=$2
	echo "warning: should not reach here!!!"
else
	ENABLE_CONNECT=0
	WAN=$1
fi

multi_ppp $WAN

if [ $L2TP_CONNECTION_TYPE = 2 ] && [ $ENABLE_CONNECT = 1 ]; then
	echo "m client" > /var/run/l2tp-control &
	#echo "c client" > /var/run/l2tp-control &
fi
