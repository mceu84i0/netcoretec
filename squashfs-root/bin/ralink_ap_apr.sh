#!/bin/sh

ap_apr=0
eval `flash get AP_APR`

if [ -f "/proc/ap_apr" ];then
	ap_apr=`cat /proc/ap_apr`
else
	exit
fi

if [ "$ap_apr" != "$AP_APR" ];then
	if [ "$ap_apr" = "1" ];then
		flash set OP_MODE 1
	else
		flash set OP_MODE 0
	fi
	flash set AP_APR $ap_apr
	flash set WLAN0_MODE 0
	eval `flash get REPEATER_ENABLED1`
	if [ "$REPEATER_ENABLED1" != "0" ];then
		flash set REPEATER_ENABLED1 0
	fi
	echo 1 > /tmp/ap_apr

	sleep 3
	ap_apr=`cat /tmp/ap_apr`
	if [ "$ap_apr" != "2" ];then
		echo "reboot by ralink_ap_apr.sh"
		reboot
	fi
	exit 0
fi

exit 1
