#! /bin/sh

#
eval `flash get DEFAULT_FLAG`
eval `flash get WAN_DHCP`

flag=0
if [ "$DEFAULT_FLAG" = "0" ]; then
	flag=2
	#if [ "$WAN_DHCP" = "3" -o "$WAN_DHCP" = "3" -o "$WAN_DHCP" = "3" ]; then
	if [ "$WAN_DHCP" = "3" ]; then
		eval `flash get PPP_USER_NAME`
		eval `flash get PPP_PASSWORD`

		if [ -z "$PPP_USER_NAME" -o -z "$PPP_PASSWORD" ]; then
			flag=1
		fi
	elif [ "$WAN_DHCP" = "1" ]; then
		eval `flash get WLAN0_ENCRYPT`
		if [ "$WLAN0_ENCRYPT" = "0" ]; then
			flag=2
		fi
	fi
fi

if [ $flag = 1 ]; then
	echo 3 > /proc/net/redirect_http
elif [ $flag = 2 ]; then
	echo 1 > /proc/net/redirect_http
else
	echo 0 > /proc/net/redirect_http
fi
