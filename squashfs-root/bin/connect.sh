#!/bin/sh
eval `flash get DNS_MODE`
eval `flash get WAN_DHCP`
eval `flash get PPP_MTU_SIZE`
eval `flash get PPTP_MTU_SIZE`
eval `flash get L2TP_MTU_SIZE`
eval `flash get PPTP_GATEWAY_ENABLE`
eval `flash get L2TP_GATEWAY_ENABLE`
eval `flash get PPTP_SUBNET_GW`
eval `flash get L2TP_GATEWAY`
eval `flash get PPTP_CONNECTION_TYPE`
eval `flash get NET_SNIFFER`

RESOLV=/var/ppp/resolv.conf
PIDFILE=/var/run/dnrd.pid
CONNECTFILE=/etc/ppp/connectfile
TMP_RT_FILE=/tmp/default_rt
ROUTER_RESOLV=/var/resolv.conf
DHCPC_RESOLV=/var/udhcpc/resolv.conf
RESOLV_CONF_STATIC=/var/ppp/resolv_static.conf

if [ "$NET_SNIFFER" = "7" ]; then
	echo 1 > /proc/net/ns_reset_tcp_seq
fi

ppp_is_defgw=0
echo "pass" > $CONNECTFILE
echo "==============================================now running connect.sh================================================="
if [ -r /etc/ppp/link ];then
	pppoe_name=`cat /etc/ppp/link`

	EXT_IP0=`ifconfig $pppoe_name | grep -i "addr:"`
	EXT_IP1=`echo $EXT_IP0 | cut -f2 -d:`
	EXT_IP=`echo $EXT_IP1 | cut -f1 -d " "`
	ppoe_ip1=`echo $EXT_IP | cut -f1 -d "."`
	ppoe_ip2=`echo $EXT_IP | cut -f2 -d "."`
	ppoe_ip3=`echo $EXT_IP | cut -f3 -d "."`

	ptpgw0=`ifconfig $pppoe_name | grep -i "P-t-P:"`
	ptpgw1=`echo $ptpgw0 | cut -f3 -d:`
	ptpgw=`echo $ptpgw1 | cut -f1 -d " "`

	if [ $WAN_DHCP = 4 ] || [ $WAN_DHCP = 8 ] || [ $WAN_DHCP = 6 ] || [ $WAN_DHCP = 9 ] || [ $WAN_DHCP = 10 ] || [ $WAN_DHCP = 11 ] || [ $WAN_DHCP = 12 ] || [ $WAN_DHCP = 13 ] || [ $WAN_DHCP = 18 ] || [ $WAN_DHCP = 19 ]; then
		if [ $WAN_DHCP = 12 ] || [ $WAN_DHCP = 13 ] || [ $WAN_DHCP = 18 ] || [ $WAN_DHCP = 19 ];then
			eval `flash get WAN_DEFAULT_GATEWAY`
			eval `flash get PPP_GATEWAY_ENABLE`
			if [ $PPP_GATEWAY_ENABLE = "0" ] ; then
				#rt_flag=0
				#PPTP_SUBNET_GW is default gw of static ip! so make sure WAN_DHCP = 4
				if [ $WAN_DEFAULT_GATEWAY != "0" ] && [ $WAN_DHCP = 12 ]; then 
  					route del -net default gw $WAN_DEFAULT_GATEWAY
					#PPTP_GW_ADDR=$PPTP_SUBNET_GW
					#rt_flag=1
				elif [ $WAN_DEFAULT_GATEWAY != "0" ] && [ $WAN_DHCP = 18 ]; then
                                         route del -net default gw $WAN_DEFAULT_GATEWAY
                                         #PPTP_GW_ADDR=$PPTP_SUBNET_GW
                                         #rt_flag=1
				elif [ $WAN_DHCP = 19 ]; then
                                         #echo " notice, here used : route del default"
                                         #route del default
                                          if [ -e $TMP_RT_FILE ]; then
                                                 mid=`cat $TMP_RT_FILE`
                                                  for i in $mid
                                                 do
                                                  route del -net default gw $i
                                                  #PPTP_GW_ADDR=$i
                                                  #rt_flag=1
                                                  done
                                          else    
                                                  echo "starting delete all default route"
                                                  while route del default
                                                  do :
                                                  done
                                                  echo "ok, deleted all default route     [connect.sh]"   
                                          fi

				elif [ $WAN_DHCP = 13 ]; then
					#echo " notice, here used : route del default"
					#route del default
					if [ -e $TMP_RT_FILE ]; then
						mid=`cat $TMP_RT_FILE`
						for i in $mid
						do
						route del -net default gw $i
						#PPTP_GW_ADDR=$i
						#rt_flag=1
						done
					else
						echo "starting delete all default route"
						while route del default 
						do :
						done
						echo "ok, deleted all default route	[connect.sh]"   
					fi
				fi
				#if [ $rt_flag = 1 ]; then
				#	route add -host $PPTP_SERVER_IP_ADDR gw $PPTP_GW_ADDR
				#fi
  				route add -net default gw $ptpgw dev $pppoe_name
				ppp_is_defgw=1
			else
				eval `flash get PPP_CONNECT_TYPE`
        			route add -net ${ppoe_ip1}.${ppoe_ip2}.${ppoe_ip3}.0 netmask 255.255.255.0 gw $ptpgw dev $pppoe_name
				route del -net default gw $ptpgw dev $pppoe_name

				#add only for demanda, it needs to del really default gw for trigger, so here we add them again
				if [ $PPP_CONNECT_TYPE = 1 ] && [ $WAN_DEFAULT_GATEWAY != "0" ] && [ $WAN_DHCP = 12 ]; then 
  					route add -net default gw $WAN_DEFAULT_GATEWAY
				elif [ $PPP_CONNECT_TYPE = 1 ] && [ $WAN_DEFAULT_GATEWAY != "0" ] && [ $WAN_DHCP = 18 ]; then
                                         route add -net default gw $WAN_DEFAULT_GATEWAY
				elif [ $PPP_CONNECT_TYPE = 1 ] && [ $WAN_DHCP = 19 ]; then
                                         if [ -e $TMP_RT_FILE ]; then
                                                 mid=`cat $TMP_RT_FILE`
                                                 for i in $mid
                                                 do
                                                 route add -net default gw $i
                                                 done
                                         fi  
				elif [ $PPP_CONNECT_TYPE = 1 ] && [ $WAN_DHCP = 13 ]; then
					if [ -e $TMP_RT_FILE ]; then
						mid=`cat $TMP_RT_FILE`
						for i in $mid
						do
						route add -net default gw $i
						done
					fi
				fi
				ppp_is_defgw=0
			fi
		fi
		if [ $WAN_DHCP = 4 ] || [ $WAN_DHCP = 8 ];then
			#if [ $PPTP_CONNECTION_TYPE = 1 ]; then			
				#echo 1 > /proc/fast_pptp
			#fi
			#echo 0 > /proc/pptp_conn_ck
			eval `flash get PPTP_SERVER_IP_ADDR`
			eval `flash get PPTP_IP_ADDR`
			if [ $PPTP_GATEWAY_ENABLE = "0" ] ; then
				#rt_flag=0
				#PPTP_SUBNET_GW is default gw of static ip! so make sure WAN_DHCP = 4
				if [ $PPTP_SUBNET_GW != "0" ] && [ $WAN_DHCP = 4 ]; then 
  					route del -net default gw $PPTP_SUBNET_GW
					#PPTP_GW_ADDR=$PPTP_SUBNET_GW
					#rt_flag=1
				elif [ $WAN_DHCP = 8 ]; then
					#echo " notice, here used : route del default"
					#route del default
					if [ -e $TMP_RT_FILE ]; then
						mid=`cat $TMP_RT_FILE`
						for i in $mid
						do
						route del -net default gw $i
						#PPTP_GW_ADDR=$i
						#rt_flag=1
						done
					else
						echo "starting delete all default route"
						while route del default 
						do :
						done
						echo "ok, deleted all default route	[connect.sh]"   
					fi
				fi
				#if [ $rt_flag = 1 ]; then
				#	route add -host $PPTP_SERVER_IP_ADDR gw $PPTP_GW_ADDR
				#fi
  				route add -net default gw $ptpgw dev $pppoe_name
				ppp_is_defgw=1
			else
				eval `flash get PPTP_CONNECTION_TYPE`
        			route add -net ${ppoe_ip1}.${ppoe_ip2}.${ppoe_ip3}.0 netmask 255.255.255.0 gw $ptpgw dev $pppoe_name
				route del -net default gw $ptpgw dev $pppoe_name

				#add only for demanda, it needs to del really default gw for trigger, so here we add them again
				if [ $PPTP_CONNECTION_TYPE = 1 ] && [ $PPTP_SUBNET_GW != "0" ] && [ $WAN_DHCP = 4 ]; then 
  					route add -net default gw $PPTP_SUBNET_GW
				elif [ $PPTP_CONNECTION_TYPE = 1 ] && [ $WAN_DHCP = 8 ]; then
					if [ -e $TMP_RT_FILE ]; then
						mid=`cat $TMP_RT_FILE`
						for i in $mid
						do
						route add -net default gw $i
						done
					fi
				fi
				ppp_is_defgw=0
			fi
		fi
		if [ $WAN_DHCP = 6 ] || [ $WAN_DHCP = 9 ];then
		eval `flash get L2TP_SERVER_IP_ADDR`
		eval `flash get L2TP_IP_ADDR`
			if [ $L2TP_GATEWAY_ENABLE = "0" ] ; then
				#rt_flag=0
				#L2TP_GATEWAY is default gw of static ip! so make sure WAN_DHCP = 6
				if [ $L2TP_GATEWAY != "0" ] && [ $WAN_DHCP = 6 ]; then 
  					route del -net default gw $L2TP_GATEWAY
					#PPTP_GW_ADDR=$L2TP_GATEWAY
					#rt_flag=1
				elif [ $WAN_DHCP = 9 ]; then
					#echo " notice, here used : route del default"
					#route del default
					if [ -e $TMP_RT_FILE ]; then
						mid=`cat $TMP_RT_FILE`
						for i in $mid
						do
							route del -net default gw $i
							#PPTP_GW_ADDR=$i
							#rt_flag=1
						done
					else
						echo "starting delete all default route"
						while route del default 
						do :
						done
						echo "ok, deleted all default route	[connect.sh]"   
					fi
				fi
				#if [ $rt_flag = 1 ]; then
				#	route add -host $L2TP_SERVER_IP_ADDR gw $PPTP_GW_ADDR
				#fi
  				route add -net default gw $ptpgw dev $pppoe_name
				ppp_is_defgw=1
			else
				eval `flash get L2TP_CONNECTION_TYPE`
				route add -net ${ppoe_ip1}.${ppoe_ip2}.${ppoe_ip3}.0 netmask 255.255.255.0 gw $ptpgw dev $pppoe_name
  				route del -net default gw $ptpgw dev $pppoe_name

				#add only for demanda, it needs to del really default gw for trigger, so here we add them again
				if [ $L2TP_CONNECTION_TYPE = 1 ] && [ $L2TP_GATEWAY != "0" ] && [ $WAN_DHCP = 6 ]; then 
  					route add -net default gw $L2TP_GATEWAY
				elif [ $L2TP_CONNECTION_TYPE = 1 ] && [ $WAN_DHCP = 9 ]; then
					if [ -e $TMP_RT_FILE ]; then
						mid=`cat $TMP_RT_FILE`
						for i in $mid
						do
							route add -net default gw $i
						done
					fi
				fi
				ppp_is_defgw=0
			fi #end of L2TP_GATEWAY_ENABLE
		fi
  		/bin/superdmz_init.sh
	fi
else
	echo "err: don't have /var/ppp/link in connect.sh"
	pppoe_name=ppp0
fi
#if [ $WAN_DHCP = 11 ]; then
#	eval `flash get PPP_UNNUMBER_IP`
#	eval `flash get PPP_UNNUMBER_MASKLEN`
#	if [ $PPP_UNNUMBER_IP != "0.0.0.0" ]; then
#		iptables -t nat -I POSTROUTING -o ppp+ -s ! $PPP_UNNUMBER_IP/$PPP_UNNUMBER_MASKLEN -j MASQUERADE
#	fi
#fi
if [ $DNS_MODE != 1 ]; then
  if [ -r "$RESOLV" ] ; then
    if [ -f $PIDFILE ]; then
      PID=`cat $PIDFILE`
	if [ -z "$PID" ]; then
		killall -9 dnrd
	else
      		kill -9 $PID 
	fi
      rm -f $PIDFILE
    fi

#add host route for dns those are getted from ppp
  if [ -n "$ptpgw" ]; then
    line=0
    cat $RESOLV | grep nameserver > /tmp/ddfile
    line=`cat /tmp/ddfile | wc -l`
    num=1
    while [ $num -le $line ];
    do
      pat0=` head -n $num /tmp/ddfile | tail -n 1`
        pat1=`echo $pat0 | cut -f2 -d " "`
	if [ $ppp_is_defgw = 0 ]; then
		route add -host $pat1 gw $ptpgw dev $pppoe_name
	fi
        num=`expr $num + 1`
    done
  fi

    if [ -r "$DHCPC_RESOLV" ]; then
	#cat $RESOLV | grep nameserver >> $ROUTER_RESOLV
	#cp -fr $ROUTER_RESOLV $RESOLV 
    	rm -fr $ROUTER_RESOLV
    	#cp $DHCPC_RESOLV $ROUTER_RESOLV
	#cat $RESOLV | grep nameserver >> $ROUTER_RESOLV
	echo "-n" > $ROUTER_RESOLV
	#cat $DHCPC_RESOLV | grep nameserver >> $ROUTER_RESOLV
	cat $RESOLV >> $ROUTER_RESOLV
	#cp -fr $ROUTER_RESOLV $RESOLV 
    elif [ -r "$RESOLV_CONF_STATIC" ]; then
    	rm -fr $ROUTER_RESOLV
    	#cp $RESOLV_CONF_STATIC $ROUTER_RESOLV
	#cat $RESOLV | grep nameserver >> $ROUTER_RESOLV
	echo "-n" > $ROUTER_RESOLV
	#cat $RESOLV_CONF_STATIC | grep nameserver >> $ROUTER_RESOLV
	cat $RESOLV >> $ROUTER_RESOLV
	#cp -fr $ROUTER_RESOLV $RESOLV 
    else
    	cp $RESOLV /var
    fi

    line=0
    cat $ROUTER_RESOLV | grep nameserver > /tmp/ddfile 
    line=`cat /tmp/ddfile | wc -l`
    num=1
    while [ $num -le $line ];
    do
      pat0=` head -n $num /tmp/ddfile | tail -n 1`
      pat1=`echo $pat0 | cut -f2 -d " "`
      DNS="$DNS -s $pat1"
      num=`expr $num + 1`
    done

    num=1
    while [ $num -le 5 ];
    do
      dnrd --cache=off $DNS
      if [ -f $PIDFILE ]; then
        break
      else
        sleep 1
        num=`expr $num + 1`
      fi
    done
    
  fi
else
	DNS="--cache=off"
	if [ -f $PIDFILE ]; then
      	PID=`cat $PIDFILE`
	if [ -z "$PID" ]; then
		killall -9 dnrd
	else
      		kill -9 $PID 
	fi
      	rm -f $PIDFILE
    	fi
	
	rm -fr $RESOLV
	
    	eval `flash get DNS1`
	if [ "$DNS1" != '0.0.0.0' ]; then
		DNS="$DNS -s $DNS1"
		echo nameserver $DNS1 > $RESOLV
	fi
	eval `flash get DNS2`
	if [ "$DNS2" != '0.0.0.0' ]; then
		DNS="$DNS -s $DNS2"
		echo nameserver $DNS2 >> $RESOLV
  	fi
	eval `flash get DNS3`
	if [ "$DNS3" != '0.0.0.0' ]; then
		DNS="$DNS -s $DNS3"
		echo nameserver $DNS3 >> $RESOLV
  	fi
  	dnrd $DNS
	cp $RESOLV /var/resolv.conf
fi

if [ $WAN_DHCP = 4 ] || [ $WAN_DHCP = 8 ]; then
  ifconfig $pppoe_name mtu $PPTP_MTU_SIZE txqueuelen 25
elif [ $WAN_DHCP = 6 ] || [ $WAN_DHCP = 9 ]; then
  ifconfig $pppoe_name mtu $L2TP_MTU_SIZE txqueuelen 25
else
  ifconfig $pppoe_name mtu $PPP_MTU_SIZE txqueuelen 25
fi
#upnp.sh
if [ -f /bin/vpn.sh ]; then
      echo 'Setup VPN'
      vpn.sh all
fi

. /etc/info.r
#restart igmpproxy
eval `flash get IGMP_PROXY_DISABLED`
killall -9 igmpproxy 2> /dev/null
if [ $IGMP_PROXY_DISABLED = 0 ]; then
	if [ "$RALINK" = "1" ];then
		igmpproxy.sh eth2.2 br0 ppp0 &
	else
		igmpproxy eth1 br0 &
	fi
	echo 128 > /proc/sys/net/ipv4/igmp_max_memberships
	route del -net 239.0.0.0 netmask 255.0.0.0 dev br0
	route add -net 239.0.0.0 netmask 255.0.0.0 dev br0
fi	

# rock: feature is decided by mkimg
###VOIP_SUPPORT###
if [ "$VOIP_SUPPORT" != "" ]; then
if [ -f  /etc/ppp/resolv.conf ]; then
   # rock: enable dns client if pppoe
   cat /etc/ppp/resolv.conf > /etc/resolv.conf
fi
fi

#restart DDNS and ntp while that is killed in disconnect.sh
eval `flash get DDNS_ENABLED`
if [ $DDNS_ENABLED = 1 ]; then
killall -9 ddns.sh 2> /dev/null
rm -f /var/firstddns 2> /dev/null
ddns.sh option
fi
eval `flash get NTP_ENABLED`
if [ $NTP_ENABLED = 1 ]; then
killall -9 ntp.sh 2> /dev/null 
killall ntpclient 2> /dev/null
 ntp.sh
fi

syslogd.sh
/bin/port_trigger.sh init $pppoe_name

