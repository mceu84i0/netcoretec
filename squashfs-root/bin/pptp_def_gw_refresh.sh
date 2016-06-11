#!/bin/sh
eval `flash get PPTP_GATEWAY_ENABLE`
eval `flash get PPTP_SUBNET_GW`
eval `flash get WAN_DHCP`
TMP_RT_FILE=/tmp/default_rt

if [ $PPTP_SUBNET_GW != "0" ] && [ $WAN_DHCP = 4 ]; then
	route del -net default gw $PPTP_SUBNET_GW
        route add -net default gw $PPTP_SUBNET_GW
fi
if [ $WAN_DHCP = 8 ]; then
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
