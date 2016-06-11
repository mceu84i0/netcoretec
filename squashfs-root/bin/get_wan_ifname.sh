#!/bin/sh

eval `flash get MULTI_PPP_MASTER`
if [ -z $WAN_DHCP ]; then
	eval `flash get WAN_DHCP`
fi

if [ $WAN_DHCP = 10 ]; then
	LINK_FILE=/etc/ppp/link_$MULTI_PPP_MASTER
elif [ $WAN_DHCP = 15 ]; then
	LINK_FILE=/etc/ppp/link_1
else
	LINK_FILE=/etc/ppp/link
fi

#if [ $WAN_DHCP = 3 ] || [ $WAN_DHCP = 4 ] || [ $WAN_DHCP = 6 ] || [ $WAN_DHCP = 8 ] || [ $WAN_DHCP = 9 ] || [ $WAN_DHCP = 10 ] || [ $WAN_DHCP = 11 ]; then
#if [ $WAN_DHCP = 3 ] || [ $WAN_DHCP = 4 ] || [ $WAN_DHCP = 6 ] || [ $WAN_DHCP = 8 ] || [ $WAN_DHCP = 9 ] || [ $WAN_DHCP = 11 ]; then
#LINK_FILE=/etc/ppp/link_$MULTI_PPP_MASTER
#if [ $WAN_DHCP = 10 ]; then	
#	if [ -r $LINK_FILE ]; then
#		echo "get wan ppp interface name from link file"
#		WAN=`cat $LINK_FILE`
#	else
#		echo "default ppp inteface name"
#		WAN=ppp0
#	fi
#elif [ $WAN_DHCP = 3 ] || [ $WAN_DHCP = 4 ] || [ $WAN_DHCP = 6 ] || [ $WAN_DHCP = 8 ] || [ $WAN_DHCP = 9 ] || [ $WAN_DHCP = 11 ]; then
#	if [ -r $LINK_FILE ]; then
#		WAN=`cat $LINK_FILE`
#	else
#		WAN=ppp0
#	fi
#fi
if [ $WAN_DHCP = 3 ] || [ $WAN_DHCP = 4 ] || [ $WAN_DHCP = 6 ] || [ $WAN_DHCP = 8 ] || [ $WAN_DHCP = 9 ] || [ $WAN_DHCP = 10 ] || [ $WAN_DHCP = 11 ] || [ $WAN_DHCP = 12 ] || [ $WAN_DHCP = 13 ]; then
	if [ -r $LINK_FILE ]; then
		#echo "get wan ppp interface name from link file"
		WAN=`cat $LINK_FILE`
	else
		#echo "default ppp inteface name"
		WAN=ppp0
	fi
elif [ $WAN_DHCP = 15 ]; then
	VLAN_WAN_FILE=/var/args/main_if
	if [ -r $VLAN_WAN_FILE ]; then
		WAN=`cat $VLAN_WAN_FILE`
	elif [ -r $LINK_FILE ]; then
		#echo "get wan ppp interface name from link file"
		WAN=`cat $LINK_FILE`
	else
		WAN=null
	fi
fi
