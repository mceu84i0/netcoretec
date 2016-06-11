#!/bin/sh
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
#
#    More Dmz Support  1: Enable 0

#
#  End

. /etc/info.r

ip=0
port1=0
port2=0
protocol=0
ZERO=0
WAN=$WANNAME
BRIDGE=br0

eval `flash get WAN_DHCP`
eval `flash get IPFILTER_TBL_NUM`
eval `flash get PORTFILTER_TBL_NUM`
eval `flash get MACFILTER_TBL_NUM`
eval `flash get PORTFW_TBL_NUM`
eval `flash get DMZ_HOST`

eval `flash get MACFILTER_RULE`
eval `flash get IPFILTER_RULE`
eval `flash get URLFILTER_RULE`
eval `flash get IPFILTER_ENABLED`
eval `flash get PORTFILTER_ENABLED`
eval `flash get MACFILTER_ENABLED`
eval `flash get PORTFW_ENABLED`
eval `flash get DMZ_ENABLED`
eval `flash get OP_MODE`
eval `flash get WEB_WAN_ACCESS_ENABLED`
eval `flash get PING_WAN_ACCESS_ENABLED`

#add by wangting
eval `flash get IP_ADDR`
eval `flash get SUBNET_MASK`
eval `flash get SUPER_DMZ_ENABLE`
#end add
eval `flash get PPTP_GATEWAY_ENABLE`
eval `flash get PPTP_SUBNET_GW`

# if wireless ISP mode , set WAN to wlan0
eval `flash get  WISP_WAN_ID`
if [ "$OP_MODE" = '2' -o "$OP_MODE" = 3  ];then
	if [ "$RALINK" = "1" ];then
		WAN=apcli0
	else
		WAN=wlan${WISP_WAN_ID}-vxd
	fi
fi

echo "======================================firewall_pptp.sh $1 $2 $3===================================="

#add for multi pppoe's slave ppp link
if [ $# -eq 3 ]; then
	WAN=$2
	if [ $1 = "disconnect" ]; then
		CMDA=-D
		CMDI=-D
	else
		CMDA=-A
		CMDI=-I
	fi
else
	CMDA=-A
	CMDI=-I
fi

if [ $# -eq 3 ]; then
	EXT_IP=$3
else
	EXT_IP0=`ifconfig $WAN | grep -i "addr:"`
	EXT_IP1=`echo $EXT_IP0 | cut -f2 -d:`
	EXT_IP=`echo $EXT_IP1 | cut -f1 -d " "`
fi

INT_IP0=`ifconfig $BRIDGE | grep -i "addr:"`
INT_IP1=`echo $INT_IP0 | cut -f2 -d:`
INT_IP=`echo $INT_IP1 | cut -f1 -d " "`
NET_SNIFFER=`flash get NET_SNIFFER`
NET_SNIFFER=`echo $NET_SNIFFER | cut -f2 -d=`



eval `flash get URLFILTER_ENABLED`
eval `flash get URLFILTER_TBL_NUM`



#add by w:ngting for superdmz
if [ $SUPER_DMZ_ENABLE = 1 ];then 
	echo "Set super dmz ..................."
	iptables -t nat $CMDA POSTROUTING -o $WAN -j SNAT --to "$EXT_IP"
	iptables -t nat $CMDA POSTROUTING -s $IP_ADDR/$SUBNET_MASK -m mark --mark 2 -j MASQUERADE
        iptables  $CMDA FORWARD  -i $WAN -d "$EXT_IP" -p all -j ACCEPT
else
	#done in slave_connect.sh
	if [ $WAN_DHCP != 10 -a $WAN_DHCP != 15 ]; then
		iptables -t nat $CMDI POSTROUTING -o $WAN -j MASQUERADE	
	fi
fi
# end add

#Remote Mgmt
#wan_dhcp == 15, this mode, not all wan interface is accessed by management
if [ $WAN_DHCP != 15 ]; then
	eval `flash get REMOTE_MGMT_ENABLE`
	eval `flash get REMOTE_MGMT_PORT`
	if [ $REMOTE_MGMT_ENABLE -gt 0 ]; then
		iptables -t mangle $CMDA PREROUTING -i $WAN -p tcp -d "$EXT_IP" --dport "$REMOTE_MGMT_PORT" -m state --state new -j MARK --set-mark 2
		iptables $CMDA INPUT  -m mark --mark 2 -j ACCEPT
		iptables -t nat $CMDA PREROUTING -p tcp -i $WAN -d $EXT_IP --dport "$REMOTE_MGMT_PORT" -j DNAT --to "$INT_IP":80
	fi
fi
#end Remote Mgmt


#Webhard Function
eval `flash get WEBHARD_ENABLED`
if [ $WEBHARD_ENABLED -gt 0 ];then
	eval `flash get WEBHARD_FTPPORT`
	eval `flash get IP_ADDR`
	iptables -t mangle $CMDA PREROUTING -i $WAN -p tcp -d "$EXT_IP" --dport "$WEBHARD_FTPPORT" -m state --state new -j MARK --set-mark 2

	iptables $CMDA PREROUTING -t nat -p TCP --dport $WEBHARD_FTPPORT:$WEBHARD_FTPPORT -d $EXT_IP -j DNAT --to $IP_ADDR:$WEBHARD_FTPPORT
	iptables $CMDA PREROUTING -t mangle -i $WAN -p TCP --dport $WEBHARD_FTPPORT:$WEBHARD_FTPPORT -d $EXT_IP -j MARK --set-mark 2
	iptables $CMDA PREROUTING -t nat -p TCP --dport 23:23 -d $EXT_IP -j DNAT --to $IP_ADDR:23
	iptables $CMDA PREROUTING -t mangle -i $WAN -p TCP --dport 23:23 -d $EXT_IP -j MARK --set-mark 2
fi
#end Webhard


PPTP_VPN=0
L2TP_VPN=0
IPSEC_VPN=0
if [ $PORTFW_TBL_NUM -gt 0 ] && [ $PORTFW_ENABLED -gt 0 ];
then
	num=1
	while [ $num -le $PORTFW_TBL_NUM ];
	do
		PORTFW_TBL=`flash get PORTFW_TBL | grep PORTFW_TBL$num=`
		port_ip=`echo $PORTFW_TBL | cut -f2 -d=`
		ip=`echo $port_ip | cut -f1 -d,`
		port1=`echo $port_ip | cut -f2 -d,`
		tmp_port=`echo $port_ip | cut -f3 -d,`
		port2=`echo $tmp_port | cut -f2 -d ' '`
		tmp_port1=` echo $port_ip | cut -f4 -d,`
		in_port1=`echo $tmp_port1 | cut -f2 -d ' '`
		tmp_port2=`echo $port_ip | cut -f5 -d,`
		in_port2=`echo $tmp_port2 | cut -f2 -d ' '`
		protocol=`echo $port_ip | cut -f6 -d,`
		num=`expr $num + 1`

		if [ $protocol = 1 ]; then
			iptables $CMDA PREROUTING -t nat -p TCP --dport $port1:$port2 -d $EXT_IP -j DNAT --to $ip:$in_port1-$in_port2 
			iptables $CMDA PREROUTING -t mangle -i $WAN -p TCP --dport $port1:$port2 -d $EXT_IP -j MARK --set-mark 2
			#iptables  $CMDA FORWARD  -i $WAN -d $ip -p TCP --dport $port1:$port2 -j ACCEPT       
		fi
		if [ $protocol = 2 ]; then
			iptables $CMDA PREROUTING -t nat -p UDP --dport $port1:$port2 -d $EXT_IP -j DNAT --to $ip:$in_port1-$in_port2 
			iptables $CMDA PREROUTING -t mangle -i $WAN -p UDP --dport $port1:$port2 -d $EXT_IP -j MARK --set-mark 2
			#iptables  $CMDA FORWARD  -i $WAN -d $ip -p UDP --dport $port1:$port2 -j ACCEPT
		fi
		if [ $protocol = 3 ]; then
			iptables $CMDA PREROUTING -t nat -p TCP --dport $port1:$port2 -d $EXT_IP -j DNAT --to $ip:$in_port1-$in_port2 
			iptables $CMDA PREROUTING -t nat -p UDP --dport $port1:$port2 -d $EXT_IP -j DNAT --to $ip:$in_port1-$in_port2 
			iptables $CMDA PREROUTING -t mangle -i $WAN -p TCP --dport $port1:$port2 -d $EXT_IP -j MARK --set-mark 2
			iptables $CMDA PREROUTING -t mangle -i $WAN -p UDP --dport $port1:$port2 -d $EXT_IP -j MARK --set-mark 2

			#iptables  $CMDA FORWARD  -i $WAN -d $ip -p TCP --dport $port1:$port2 -j ACCEPT
			#iptables  $CMDA FORWARD  -i $WAN -d $ip -p UDP --dport $port1:$port2 -j ACCEPT
		fi

		if [ $PPTP_VPN = 0 ]; then
			if [ $port1 -le 1723 ] && [ $port2 -ge 1723 ];then
				if [ $protocol = 1 ] || [ $protocol = 3 ]; then	    	 	
					iptables $CMDA PREROUTING -t nat -i $WAN -p gre -d $EXT_IP -j DNAT --to $ip
					iptables $CMDA FORWARD -i $WAN -p gre -j ACCEPT	

					PPTP_VPN=1
				fi
			fi
		fi


		if [ $IPSEC_VPN = 0 ]; then
			if [ $port1 -le 500 ] && [ $port2 -ge 500 ];then
				if [ $protocol = 2 ] || [ $protocol = 3 ]; then
					iptables $CMDA PREROUTING -t nat -p esp -d $EXT_IP -j DNAT --to $ip 
					iptables $CMDA PREROUTING -t nat -p udp --dport 4500 -d $EXT_IP -j DNAT --to $ip 
					IPSEC_VPN=1
				fi
			fi
		fi

	done
fi

eval `flash get VPN_PASSTHRU_IPSEC_ENABLED`
if [ $IPSEC_VPN != 0 ] || [ $VPN_PASSTHRU_IPSEC_ENABLED != 0 ];then
        iptables $CMDA FORWARD -p udp --dport 500 -i $WAN -o br0 -j ACCEPT
fi
if  [ $WAN_DHCP = 0 ]; then
	eval `flash get SECONDARY_ENABLE`



	if [ $SECONDARY_ENABLE -gt 0 ]; then

		eval `flash get SECONDARY_WAN_IP_ADDR`
		eval `flash get SECONDARY_WAN_SUBNET_MASK`
		eval `flash get SECONDARY_DNZ`


		iptables $CMDA PREROUTING -t mangle -i $WAN -p ALL -d $SECONDARY_WAN_IP_ADDR -j MARK --set-mark 2
	fi
fi
###Upnp ######################


###End################

if [ "$DMZ_HOST" != '0.0.0.0' ] && [ $DMZ_ENABLED -gt 0 ];
then
	iptables $CMDA PREROUTING -t mangle -i $WAN -p ALL -d $EXT_IP -j MARK --set-mark 2
	if [ $WAN_DHCP = 1 ]; then 
		iptables -t nat $CMDI PREROUTING 1 -d $EXT_IP -p udp --dport 68 -j RETURN
	fi
	iptables $CMDA PREROUTING -t nat -p ALL -d $EXT_IP -j DNAT --to $DMZ_HOST 
	#iptables  $CMDA FORWARD  -i $WAN -d $DMZ_HOST -p all -j ACCEPT
fi


#deny the ping request from WAN interface to bridge interface
if [ "$EXT_IP" != '' ];then
	if [ $PING_WAN_ACCESS_ENABLED = 0 ]; then
		iptables $CMDA INPUT -p icmp --icmp-type echo-request -i $WAN -d $EXT_IP -j DROP
	else
		iptables $CMDA INPUT -p icmp --icmp-type echo-request -i $WAN -d $EXT_IP -j ACCEPT
	fi
fi

if [ "$EXT_IP" != '' ] ; then
	if [ $WEB_WAN_ACCESS_ENABLED = 0 ]; then
		iptables $CMDA INPUT -p tcp --dport 80:80 -i $WAN -d $EXT_IP -j DROP
	else
		iptables $CMDA INPUT -p tcp --dport 80:80 -i $WAN -d $EXT_IP -j ACCEPT
	fi
fi

# voip: allow SNMP udp port 
if [ "$EXT_IP" != '' ] && [ -f /bin/snmpd ]; then
	iptables $CMDA INPUT -p udp --dport 161:161 -i $WAN -d $EXT_IP -j ACCEPT
fi

# voip: setup VoIP ports, ###xxx### will be modified by mkimg
###NUM_VOIP_PORTS###
###CONFIG_IP_NF_MATCH_MULTIPORT###
###CONFIG_IP_NF_MATCH_MPORT###
if [ "$EXT_IP" != '' ] && [ -f /bin/solar ]; then
	i=0
	SIP_PORTS=
	RTP_PORTS=
	while [ $i -lt $NUM_VOIP_PORTS ];
	do
		# add SIP rules
		SIP_PORT=`flash voip get VOIP.PORT[$i].SIP_PORT | cut -f2 -d=`
		# add RTP rules
		RTP_PORT_START=`flash voip get VOIP.PORT[$i].MEDIA_PORT | cut -f2 -d=`
		RTP_PORT_END=`expr $RTP_PORT_START + 3`
		RTP_PORT="$RTP_PORT_START:$RTP_PORT_END"
		if [ "$i" = "0" ]; then
			SIP_PORTS=$SIP_PORT
			RTP_PORTS=$RTP_PORT
		else
			SIP_PORTS="$SIP_PORTS,$SIP_PORT"
			RTP_PORTS="$RTP_PORTS,$RTP_PORT"
		fi
		if [ "$CONFIG_IP_NF_MATCH_MPORT" = "y" ]; then
			: # SIP/RTP use mport in the end
		else
			iptables $CMDI PREROUTING -t nat -i $WAN -p udp --dport $RTP_PORT -j ACCEPT
			if [ "$CONFIG_IP_NF_MATCH_MULTIPORT" = "y" ]; then
				: # SIP use multiport in the end
			else
				iptables $CMDA INPUT -i $WAN -p udp --dport $SIP_PORT -j ACCEPT
				iptables $CMDI PREROUTING -t nat -i $WAN -p udp --dport $SIP_PORT -j ACCEPT
			fi
		fi
		i=`expr $i + 1`
	done
	if [ "$CONFIG_IP_NF_MATCH_MPORT" = "y" ]; then
		iptables $CMDA INPUT -i $WAN -p udp -m mport --dport $SIP_PORTS -j ACCEPT
		iptables $CMDI PREROUTING -t nat -i $WAN -p udp -m mport --dport $SIP_PORTS,$RTP_PORTS -j ACCEPT
	elif [ "$CONFIG_IP_NF_MATCH_MULTIPORT" = "y" ]; then
		iptables $CMDA INPUT -i $WAN -p udp -m multiport --dport $SIP_PORTS -j ACCEPT
		iptables $CMDI PREROUTING -t nat -i $WAN -p udp -m multiport --dport $SIP_PORTS -j ACCEPT
	fi
fi
# rock: accept igmp in WAN
eval `flash get IGMP_PROXY_DISABLED`
if [ "$IGMP_PROXY_DISABLED" = 0 ]; then
	iptables $CMDA INPUT -i $WAN -p igmp -j ACCEPT
fi

if [ $WAN_DHCP != 15 ]; then
	iptables $CMDA INPUT -i ! $WAN -j ACCEPT
fi

# let ipsec packet come in
#-- keith: add l2tp support. 20080515
if [ -f /bin/vpn.sh ] && [ $WAN_DHCP != 4 ] && [ $OP_MODE != 1 ] && [ $WAN_DHCP != 6 ] && [ $WAN_DHCP != 8 ] && [ $WAN_DHCP != 9 ] && [ $WAN_DHCP != 10 ] && [ $WAN_DHCP != 11 ]; then 
	eval `flash get IPSECTUNNEL_ENABLED`
	if [ $IPSECTUNNEL_ENABLED -gt 0 ]; then
		iptables $CMDA INPUT -p 50 -i $WAN -j ACCEPT
		iptables $CMDA INPUT -p 51 -i $WAN -j ACCEPT
		iptables $CMDA INPUT -p udp --sport 500 --dport 500 -i $WAN -j ACCEPT
	fi
fi

eval `flash get IGMP_PROXY_DISABLED`
if [ $IGMP_PROXY_DISABLED = 0 ]; then
	iptables $CMDA FORWARD -i $WAN -p udp -m udp --destination  224.0.0.0/4 -j ACCEPT
fi
iptables $CMDA FORWARD -p 50 -i $WAN -o $BRIDGE -j ACCEPT
iptables  $CMDA FORWARD -i $WAN -m state --state ESTABLISHED,RELATED -j ACCEPT


if [ -r "/proc/net/ns" ] && [ $NET_SNIFFER != "0" ];then
	if [ "$NS_VER" = "5v1" -o "$NS_VER" = "5v2" -o $NET_SNIFFER -eq 5 -o $NET_SNIFFER -eq 51 -o $NET_SNIFFER -eq 52 ];then
		iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ALL SYN -j TCPWINSIZE --set-winsize 18400
		iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ACK ACK -j TCPWINSIZE --set-winsize 18400
	else
		#linxiaobin@2010.1.7
		if [ $NET_SNIFFER = "6" ];then
			iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags RST,ACK RST -j TCPWINSIZE --set-winsize 0
			iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ALL SYN -j TCPWINSIZE --set-winsize 44631
			iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ACK ACK -j TCPWINSIZE --set-winsize 44631

		else
			eval `flash get SPECIAL_CONNECT_ENABLE`
			eval `flash get SPECIAL_CONNECT`
			eval `flash get HENAN_DHCP_ENABLE`
			#if [ "$WAN_DHCP" = '3' ] && [ $SPECIAL_CONNECT_ENABLE -gt 0 -o "$HENAN_DHCP_ENABLE" = '1' ] && [ $NET_SNIFFER = "2" ]; then
			if [ "$WAN_DHCP" = '3' ] && [ $SPECIAL_CONNECT_ENABLE -gt 0 -a "$SPECIAL_CONNECT" = "henan" ] && [ $NET_SNIFFER = "2" ]; then
			      echo "---------------------------changed henan_pppoe/dhcp's winsize--------------------------------"
				iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ALL SYN -j TCPWINSIZE --set-winsize 16442
				iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ACK ACK -j TCPWINSIZE --set-winsize 16442
			elif [ "$WAN_DHCP" = '1' ] && [ "$HENAN_DHCP_ENABLE" = '1' ] && [ $NET_SNIFFER = "2" ]; then
				iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ALL SYN -j TCPWINSIZE --set-winsize 16442
				iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ACK ACK -j TCPWINSIZE --set-winsize 16442
			else	
			
				iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ALL SYN -j TCPWINSIZE --set-winsize 30000
				iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ACK ACK -j TCPWINSIZE --set-winsize 35000
			fi
		fi
	fi
	iptables -t mangle $CMDA POSTROUTING -o $WAN -p tcp --tcp-flags ALL SYN -j TCPMSS --set-mss 1440
	iptables -t mangle $CMDA POSTROUTING -o $WAN -j TTL --ttl-set 128
fi
