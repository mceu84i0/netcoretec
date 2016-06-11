#!/bin/sh
#WAN=eth1
OPTIONS=/etc/ppp/henan_dhcp.conf
#notes: $IPOPT file is static,can't changed! it's used in another place
IPOPT=/var/udhcpc/wan.info

eval `flash get HENAN_DHCP_USER_NAME`
eval `flash get HENAN_DHCP_PASSWD`

echo "USERNAME=$HENAN_DHCP_USER_NAME" > $OPTIONS
echo "PASSWORD=$HENAN_DHCP_PASSWD" >> $OPTIONS

echo "WANIP=0.0.0.0" > $IPOPT
echo "SERVER=0.0.0.0" >> $IPOPT

henan $OPTIONS &


#PID_FILE=/var/run/ppp0.pid



