#!/bin/sh
#WAN=eth1
OPTIONS=/etc/ppp/guangdian.static.conf

#eval `flash get GUANGDIAN_LOCAL_IP_ADDR`
#eval `flash get GUANGDIAN_LOCAL_MAC_ADDR`

#ifconfig eth1 $GUANGDIAN_LOCAL_IP_ADDR
#ifconfig eth1 hw ether $GUANGDIAN_LOCAL_MAC_ADDR

flash gen-guangdian $OPTIONS 
guangdian $OPTIONS &


#PID_FILE=/var/run/ppp0.pid



