#!/bin/sh
#
# script file to add/del iptables  for routing-loop when l2tp_dhcp and pptp_dhcp
#


if [ $# -lt 1 ]; then echo "Usage: $0 {add|del]";  exit 1 ; fi

LINK_FILE=/etc/ppp/link
GETMIB="flash get"
eval `$GETMIB WAN_DHCP`

#if vpn is disconnect, then what have added will lost, so not need to del them 
if [ $WAN_DHCP = 8 -o $WAN_DHCP = 9 ] && [ -r $LINK_FILE ]; then
	if [ $1 = "add" ]; then
		iptables -A OUTPUT -o ppp+ -j DROP
		#iptables -A FORWARD -o ppp+ -j DROP
	else
		if [ $# -lt 2 ]; then
			iptables -D OUTPUT -o ppp+ -j DROP
			#iptables -D FORWARD -o ppp+ -j DROP
		elif [ $2 -gt 0 ]; then
			num=1
			while [ $num -le $2 ]; 
			do
				iptables -D OUTPUT -o ppp+ -j DROP
				#iptables -D FORWARD -o ppp+ -j DROP
				num=`expr $num + 1`
			done	
		#else
			#iptables -D OUTPUT -o ppp+ -j DROP
		fi
	fi	
	
fi
