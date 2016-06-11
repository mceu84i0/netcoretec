#!/bin/sh
eval `flash get WAN_DHCP`
eval `flash get WAN_DEFAULT_GATEWAY`
eval `flash get PPP_GATEWAY_ENABLE`
TMP_RT_FILE=/tmp/default_rt

if [ $WAN_DEFAULT_GATEWAY != "0" ] && [ $WAN_DHCP = 12 ]; then
	route del -net default gw $WAN_DEFAULT_GATEWAY
        route add -net default gw $WAN_DEFAULT_GATEWAY
fi
if [ $WAN_DHCP = 13 ]; then
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
