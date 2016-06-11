#!/bin/sh

LAN=br0
WAN=eth2.2

WAN_IP=$1

eval `flash get DMZ_ENABLED`
eval `flash get MULTI_DMZ_TBL_NUM`
eval `flash get WAN_DHCP`

if [ "$DMZ_ENABLED" = "1" ];then
	num=1
	while [ $num -le $MULTI_DMZ_TBL_NUM ];
	do
		MULTI_DMZ_TBL=`flash get MULTI_DMZ_TBL | grep MULTI_DMZ_TBL$num=`
		dmz_entry=`echo $MULTI_DMZ_TBL | cut -f2 -d=`
		public_ip=`echo $dmz_entry | cut -f1 -d,`
		host_ip=`echo $dmz_entry | cut -f2 -d,`

		if [ "$public_ip" = "0.0.0.0" ];then
			iptables -A PREROUTING -t mangle -i $WAN -p ALL -d $WAN_IP -j MARK --set-mark 2
			if [ $WAN_DHCP = 1 ]; then 
				iptables -t nat -I PREROUTING 1 -d $WAN_IP -p udp --dport 68 -j RETURN
			fi
			iptables -A PREROUTING -t nat -p ALL -i ! $LAN -d $WAN_IP -j DNAT --to $host_ip
		else
			iptables -A PREROUTING -t mangle -i $WAN -p ALL -d $public_ip -j MARK --set-mark 2
			if [ $WAN_DHCP = 1 ]; then 
				iptables -t nat -I PREROUTING 1 -d $public_ip -p udp --dport 68 -j RETURN
			fi
			iptables -A PREROUTING -t nat -p ALL -i ! $LAN -d $public_ip -j DNAT --to $host_ip
		fi
		num=`expr $num + 1`
	done
fi
