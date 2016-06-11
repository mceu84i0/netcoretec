#!/bin/sh
#$1:	connect/disconnect
#$2:	interface
#$3:	remote ipaddr or refresh_iptables
#$4:	local ipaddr
#$5:	vlan num, when WAN_DHCP == 15

if [ $# -lt 4 ]; then
        echo "sh arguments err: need four arguments"
        exit 1
fi

eval `flash get WAN_DHCP`
if [ $1 = "disconnect" ]; then
	echo "================= running slave-connect.sh disconnect ========================"
	if [ $WAN_DHCP != 15 ]; then
		rm -f /etc/ppp/rst_firewall
	else
		cat /etc/ppp/rst_firewall | grep -v $2 > /etc/ppp/rst_firewall
	fi
        ENABLE=0
	#REFRESH=0
else
	ENABLE=1

	#set REFRESH 's value : it for refreshing iptables
	#if [ $# -lt 3 ]; then
	#        REFRESH=0
	#else
		if [ $3 = "refresh_iptables" ]; then
		        REFRESH=1
		else
		        REFRESH=0
		fi
	#fi
	#/etc/ppp/rst_firewall, will be callde in master script file
	if [ $REFRESH = 0 ]; then
		#echo sh -vx /bin/slave_connect.sh $1 $2 refresh_iptables $4 > /etc/ppp/rst_firewall
		if [ $WAN_DHCP != 15 ]; then
        		echo /bin/slave_connect.sh $1 $2 refresh_iptables $4 >> /etc/ppp/rst_firewall
		else
        		echo /bin/slave_connect.sh $1 $2 refresh_iptables $4 $5 >> /etc/ppp/rst_firewall
		fi
		echo "================= running slave-connect.sh connect ============================"
	else
		echo "================= refresh slave-connect.sh connect ============================"
	fi
fi

if [ $WAN_DHCP != 15 ]; then
	eval `flash get MULTI_PPP_MASTER`

	if [ $MULTI_PPP_MASTER = 1 ]; then
		SLAVENUM=2
	else
		SLAVENUM=1
	fi


	if [ $ENABLE = 1 ]; then
		#adding route rule and iptables
		if [ $REFRESH = 0 ]; then
			mtustr=`flash get PPP_MTU_SIZE_$SLAVENUM`
			mtu=`echo $mtustr | cut -f2 -d=`
			ifconfig $2 mtu $mtu txqueuelen 25
		fi

		#echo "------------------------------------call firewall_pptp.sh $1 $2----------------------------------------"
		firewall_pptp.sh $1 $2 $4
		#sh -xv /bin/firewall_pptp.sh $1 $2 $4
		
		lantypestr=`flash get PPP_LAN_TYPE_$SLAVENUM`
		lantype=`echo $lantypestr | cut -f2 -d=`

		domain_flag=0	
		if [ $lantype = 0 ]; then
			numstr=`flash get PPP_POLICY_NUM_$SLAVENUM`
			RULE_NUM=`echo $numstr | cut -f2 -d=`
			
			CMD=PPP_POLICY_ROUTE_$SLAVENUM
			
			num=1
			while [ $num -le $RULE_NUM ];
			do
				str=`flash get $CMD | grep $CMD$num=`
				str_tmp=`echo $str | cut -f2 -d=`
				type=`echo $str_tmp | cut -f1 -d,`
				key1=`echo $str_tmp | cut -f2 -d,`
				key2=`echo $str_tmp | cut -f3 -d,`
				if [ $type = 1 ]; then
					#iptables -A PREROUTING -t mangle -i br0 -m iprange --dst-range $key1-$key2 -j MARK --set-mark 0xc0
					#notice: here add double for 8196b and 8196c, they are different
					iptables -I PREROUTING -t mangle -i br0 -m iprange --dst-range $key1-$key2 -j MARK --set-mark 0xc0
					iptables -A PREROUTING -t mangle -i br0 -m iprange --dst-range $key1-$key2 -j MARK --set-mark 0xc0
					#iptables -I OUTPUT -t mangle -i br0 -m iprange --dst-range $key1-$key2 -j MARK --set-mark 0xc0
				elif [ $type = 2 ]; then
					#iptables -A PREROUTING -t mangle -i br0 -p tcp --dport $key1:$key2 -j MARK --set-mark 0xc0
					iptables -I PREROUTING -t mangle -i br0 -p tcp --dport $key1:$key2 -j MARK --set-mark 0xc0
					iptables -A PREROUTING -t mangle -i br0 -p tcp --dport $key1:$key2 -j MARK --set-mark 0xc0
					#iptables -I OUTPUT -t mangle -i br0 -p tcp --dport $key1:$key2 -j MARK --set-mark 0xc0
				elif [ $type = 3 ]; then
					#iptables -A PREROUTING -t mangle -i br0 -p udp --dport $key1:$key2 -j MARK --set-mark 0xc0
					iptables -I PREROUTING -t mangle -i br0 -p udp --dport $key1:$key2 -j MARK --set-mark 0xc0
					iptables -A PREROUTING -t mangle -i br0 -p udp --dport $key1:$key2 -j MARK --set-mark 0xc0
					#iptables -I OUTPUT -t mangle -i br0 -p udp --dport $key1:$key2 -j MARK --set-mark 0xc0
				elif [ $type = 4 ]; then
					if [ $REFRESH = 0 ]; then
						echo a $key1 > /proc/net/domain_policy_rt
						domain_flag=1
					fi
				fi
				num=`expr $num + 1`
			done
			
			iptables -A POSTROUTING -t nat -o $2 -j MASQUERADE
		else
			#unnumstr=`flash get PPP_UNNUMBER_IP_$SLAVENUM`
			#unnum=`echo $unnumstr | cut -f2 -d=`
			#maskstr=`flash get PPP_UNNUMBER_MASKLEN_$SLAVENUM`
			#mask=`echo $maskstr | cut -f2 -d=`
			eval `cat /etc/ppp/policy_netmask`
		
			#in : mangle's PREROUTING link, not fall through!!! becasue: maybe be in module MARK 
			#iptables -I PREROUTING -t mangle -i br0 -s $unnum/$mask -j MARK --set-mark 0xc0
			#iptables -F POSTROUTING -t nat
			#iptables -A POSTROUTING -t nat -o ppp+ -s ! $unnum/$mask -j MASQUERADE
			
			iptables -I PREROUTING -t mangle -i br0 -s $UNNUM_NET/$UNNUM_LEN -j MARK --set-mark 0xc0
			iptables -A PREROUTING -t mangle -i br0 -s $UNNUM_NET/$UNNUM_LEN -j MARK --set-mark 0xc0
			iptables -F POSTROUTING -t nat
			iptables -A POSTROUTING -t nat -o ppp+ -s ! $UNNUM_NET/$UNNUM_LEN -j MASQUERADE

			if [ $REFRESH = 0 ]; then
				ip route add $UNNUM_NET/$UNNUM_LEN dev br0 
			fi
		fi
		if [ $REFRESH = 0 ]; then
			eval `cat /etc/ppp/policy_netmask`
			
			ip rule add fwmark 0xc0 table 0xc0
			ip route add default via $3 dev $2 table 0xc0
			ip route add $LAN_NET/$MASK_LEN dev br0 table 0xc0

			ip route flush cache

			if [ $domain_flag = 1 ]; then
				echo s 192 > /proc/net/domain_policy_rt
			fi
			#this only is used by 8196b in kernel for last packet's time
			echo r 192 > /proc/net/domain_policy_rt
		fi
	else
		#deleting route rule and iptables
		lantypestr=`flash get PPP_LAN_TYPE_$SLAVENUM`
		lantype=`echo $lantypestr | cut -f2 -d=`

		#echo "------------------------------------call firewall_pptp.sh $1 $2----------------------------------------"
		firewall_pptp.sh $1 $2 $4
		#sh -xv /bin/firewall_pptp.sh $1 $2 $4

		if [ $lantype = 0 ]; then
			numstr=`flash get PPP_POLICY_NUM_$SLAVENUM`
			RULE_NUM=`echo $numstr | cut -f2 -d=`

			CMD=PPP_POLICY_ROUTE_$SLAVENUM

			num=1
			while [ $num -le $RULE_NUM ];
			do
				str=`flash get $CMD | grep $CMD$num=`
				str_tmp=`echo $str | cut -f2 -d=`
				type=`echo $str_tmp | cut -f1 -d,`
				key1=`echo $str_tmp | cut -f2 -d,`
				key2=`echo $str_tmp | cut -f3 -d,`
				if [ $type = 1 ]; then
					iptables -D PREROUTING -t mangle -i br0 -m iprange --dst-range $key1-$key2 -j MARK --set-mark 0xc0
					iptables -D PREROUTING -t mangle -i br0 -m iprange --dst-range $key1-$key2 -j MARK --set-mark 0xc0
	#iptables -D OUTPUT -t mangle -i br0 -m iprange --dst-range $key1-$key2 -j MARK --set-mark 0xc0
				elif [ $type = 2 ]; then
					iptables -D PREROUTING -t mangle -i br0 -p tcp --dport $key1:$key2 -j MARK --set-mark 0xc0
					iptables -D PREROUTING -t mangle -i br0 -p tcp --dport $key1:$key2 -j MARK --set-mark 0xc0
	#iptables -D OUTPUT -t mangle -i br0 -p tcp --dport $key1:$key2 -j MARK --set-mark 0xc0
				elif [ $type = 3 ]; then
					iptables -D PREROUTING -t mangle -i br0 -p udp --dport $key1:$key2 -j MARK --set-mark 0xc0
					iptables -D PREROUTING -t mangle -i br0 -p udp --dport $key1:$key2 -j MARK --set-mark 0xc0
	#iptables -D OUTPUT -t mangle -i br0 -p udp --dport $key1:$key2 -j MARK --set-mark 0xc0
				elif [ $type = 4 ]; then
					echo d $key1 > /proc/net/domain_policy_rt
				fi
				num=`expr $num + 1`
			done

			iptables -D POSTROUTING -t nat -o $2 -j MASQUERADE
			/bin/route.sh add &

			eval `flash get DOMAINNAME_TBL_NUM`
			if [ $DOMAINNAME_TBL_NUM -gt 0 ]; then
				eval `flash get IP_ADDR`
				iptables -I PREROUTING -t nat -i br0 -p udp --dport 53 -j DNAT --to $IP_ADDR
			fi
		else
			#unnumstr=`flash get PPP_UNNUMBER_IP_$SLAVENUM`
			#unnum=`echo $unnumstr | cut -f2 -d=`
			#maskstr=`flash get PPP_UNNUMBER_MASKLEN_$SLAVENUM`
			#mask=`echo $maskstr | cut -f2 -d=`
			eval `cat /etc/ppp/policy_netmask`
		
			#iptables -D PREROUTING -t mangle -i br0 -s $unnum/$mask -j MARK --set-mark 0xc0
			iptables -D PREROUTING -t mangle -i br0 -s $UNNUM_NET/$UNNUM_LEN -j MARK --set-mark 0xc0
			iptables -D PREROUTING -t mangle -i br0 -s $UNNUM_NET/$UNNUM_LEN -j MARK --set-mark 0xc0
			iptables -F POSTROUTING -t nat
			iptables -A POSTROUTING -t nat -o ppp+ -j MASQUERADE

			ip route del $UNNUM_NET/$UNNUM_LEN dev br0 
		fi
		
		echo s 0 > /proc/net/domain_policy_rt
		echo r 0 > /proc/net/domain_policy_rt

		ip rule del fwmark 0xc0 table 0xc0
		ip route flush table 0xc0
		ip route flush cache
	fi
else

	if [ $ENABLE = 1 ]; then
		#adding route rule and iptables
		#if [ $REFRESH = 0 ]; then
		#	ifconfig $2 mtu $mtu txqueuelen 25
		#fi

		#echo "------------------------------------call firewall_pptp.sh $1 $2----------------------------------------"
		firewall_pptp.sh $1 $2 $4
		#sh -xv /bin/firewall_pptp.sh $1 $2 $4
		
		domain_flag=0	
		#			if [ $REFRESH = 0 ]; then
		#				echo a $key1 > /proc/net/domain_policy_rt
		#				domain_flag=1
		#			fi
		#		num=`expr $num + 1`
			
		iptables -A POSTROUTING -t nat -o $2 -j MASQUERADE
		if [ $REFRESH = 0 ]; then
			if [ -r "/bin/dns.sh" ]; then
				dns.sh 
			fi
		#	ip rule add fwmark 0xc0 table 0xc0
		#	ip route add default via $3 dev $2 table 0xc0

		#	ip route flush cache

			#if [ $domain_flag = 1 ]; then
			#	echo s 192 > /proc/net/domain_policy_rt
			#fi
			#this only is used by 8196b in kernel for last packet's time
			#echo r 192 > /proc/net/domain_policy_rt
			set_policy_routing.sh $2 $3 $5 1
		fi

		#Remote Mgmt
		eval `flash get REMOTE_VLAN_ID`
		eval `flash get REMOTE_MGMT_ENABLE`
		if [ $REMOTE_MGMT_ENABLE -gt 0 -a $REMOTE_VLAN_ID = $5 ]; then
			eval `flash get REMOTE_MGMT_PORT`
			eval `flash get IP_ADDR`
			iptables -t mangle -A PREROUTING -i $2 -p tcp -d "$4" --dport "$REMOTE_MGMT_PORT" -m state --state new -j MARK --set-mark 2
			iptables -A INPUT  -m mark --mark 2 -j ACCEPT
			iptables -t nat -A PREROUTING -p tcp -i $2 -d $4 --dport "$REMOTE_MGMT_PORT" -j DNAT --to "$IP_ADDR":80
		fi
	else
		#deleting route rule and iptables

		#echo "------------------------------------call firewall_pptp.sh $1 $2----------------------------------------"
		firewall_pptp.sh $1 $2 $4
		#sh -xv /bin/firewall_pptp.sh $1 $2 $4

	#			if [ $type = 4 ]; then
	#				echo d $key1 > /proc/net/domain_policy_rt
	#			fi
	#			num=`expr $num + 1`

		iptables -D POSTROUTING -t nat -o $2 -j MASQUERADE
		
		#echo s 0 > /proc/net/domain_policy_rt
		#echo r 0 > /proc/net/domain_policy_rt

		#ip rule del fwmark 0xc0 table 0xc0
		#ip route flush table 0xc0
		#ip route flush cache
		set_policy_routing.sh $2 $3 $5 0

		#Remote Mgmt
		eval `flash get REMOTE_VLAN_ID`
		eval `flash get REMOTE_MGMT_ENABLE`
		if [ $REMOTE_MGMT_ENABLE -gt 0 -a $REMOTE_VLAN_ID = $5 ]; then
			eval `flash get REMOTE_MGMT_PORT`
			eval `flash get IP_ADDR`
			iptables -t mangle -D PREROUTING -i $2 -p tcp -d "$4" --dport "$REMOTE_MGMT_PORT" -m state --state new -j MARK --set-mark 2
			iptables -D INPUT  -m mark --mark 2 -j ACCEPT
			iptables -t nat -D PREROUTING -p tcp -i $2 -d $4 --dport "$REMOTE_MGMT_PORT" -j DNAT --to "$IP_ADDR":80
		fi
	fi

	/bin/set_default_route.sh &
fi
