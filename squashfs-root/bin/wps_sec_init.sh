#!/bin/sh
	sleep 5
	/sbin/ifconfig wlan0-vxd down
	/bin/init.sh gw bridge
