#!/bin/sh
eval `flash get L2TP_GATEWAY_ENABLE`
eval `flash get L2TP_GATEWAY`
eval `flash get WAN_DHCP`
TMP_RT_FILE=/tmp/default_rt

if [ $L2TP_GATEWAY != "0" ] && [ $WAN_DHCP = 6 ]; then
	route del -net default gw $L2TP_GATEWAY
        route add -net default gw $L2TP_GATEWAY
fi
if [ $WAN_DHCP = 9 ]; then
	if [ -e $TMP_RT_FILE ]; then
		mid=`cat $TMP_RT_FILE`

		for i in $mid
		do
			route del -net default gw $i
			route add -net default gw $i
		done
	else
		echo "err: $TMP_RT_FILE is not exist"
	fi
fi
route del 0.0.0.0
