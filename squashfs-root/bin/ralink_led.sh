#!/bin/sh
eval `flash get WLAN_DISABLED`
if [ "$WLAN_DISABLED" = '1' ];then
	ifconfig ra0 up
	iwpriv ra0 set RadioOn=0
	ifconfig ra0 down
fi
