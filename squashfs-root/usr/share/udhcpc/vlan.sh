#!/bin/sh

#eval `flash get WAN_DHCP`

if [ "$1" = "bound" ]; then
	exec /usr/share/udhcpc/vlan.$1
else
	exec "/var/udhcpc/"$interface"."$1
fi
