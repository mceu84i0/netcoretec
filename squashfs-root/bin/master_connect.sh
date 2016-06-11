#!/bin/sh

START_FIREWALL=firewall.sh
eval `flash get DNS_MODE`
eval `flash get WAN_DHCP`
RESOLV=/etc/ppp/resolv.conf
PIDFILE=/var/run/dnrd.pid

#echo "$0 $1 $2 $3 $4"
if [ $# -lt 4 ]; then
	echo "sh arguments err: need four arguments,---------$0,$1,$2,$3"
	exit 1
fi

if [ $1 = "disconnect" ]; then
	ENABLE=0
else
	ENABLE=1
fi

DEFAULT_ROUTE_IF=$2

echo "************************starting master_connect.sh******************************"

if [ $WAN_DHCP != 15 ]; then
	eval `flash get MULTI_PPP_MASTER`
	if [ $MULTI_PPP_MASTER = 1 ]; then
		SLAVENUM=2
	else
		SLAVENUM=1
	fi

	if [ $ENABLE = 1 ]; then
		/bin/superdmz_init.sh
		mtustr=`flash get PPP_MTU_SIZE_$SLAVENUM`
		mtu=`echo $mtustr | cut -f2 -d=`
		ifconfig $DEFAULT_ROUTE_IF mtu $mtu txqueuelen 25

		#start those program: ntp.sh, dnrd, ddns.sh, igmpproxy
		if [ $DNS_MODE != 1 ]; then
			if [ -r "$RESOLV" ] ; then
				if [ -f $PIDFILE ]; then
					PID=`cat $PIDFILE`
					kill -9 $PID 
					rm -f $PIDFILE
				fi
				line=0
				cat $RESOLV | grep nameserver > /tmp/ddfile 
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
		    
				cp $RESOLV /var
			fi
		else
			DNS="--cache=off"
			if [ -f $PIDFILE ]; then
				PID=`cat $PIDFILE`
				kill -9 $PID 
				rm -f $PIDFILE
			fi
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

		#upnp.sh
		if [ -f /bin/vpn.sh ]; then
		      echo 'Setup VPN'
		      vpn.sh all
		fi

		#restart igmpproxy
		eval `flash get IGMP_PROXY_DISABLED`
		killall -9 igmpproxy 2> /dev/null
		if [ $IGMP_PROXY_DISABLED = 0 ]; then
			igmpproxy $DEFAULT_ROUTE_IF br0 &
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
		#start firewall.sh
		#echo "-----------------------start firewall.sh for master pppoe-----------------------------------"
		$START_FIREWALL

		#################################################################################################################
		#kill those program: ntp.sh, dnrd, ddns.sh, igmpproxy
	else

		killall -9 ntp.sh 2> /dev/null
		rm -f /var/ntp_run 2> /dev/null
		###########kill sleep that ntp.sh created###############
		TMPFILEDDNS=/tmp/tmpfileddns
		line=0
		ps | grep "sleep 86400" > $TMPFILEDDNS
		line=`cat $TMPFILEDDNS | wc -l`
		num=1
		while [ $num -le $line ];
		do
			pat0=` head -n $num $TMPFILEDDNS | tail -n 1`
			pat1=`echo $pat0 | cut -f1 -dS`
			pat2=`echo $pat1 | cut -f1 -d " "`
			kill -9 $pat2 2> /dev/null

			num=`expr $num + 1`
		done
		###########################
		#killall -9 ddns.sh 2> /dev/null
		###########kill sleep that ddns.sh created###############
		#TMPFILEDDNS=/tmp/tmpfileddns
		#line=0
		#ps | grep "sleep 86430" > $TMPFILEDDNS
		#line=`cat $TMPFILEDDNS | wc -l`
		#num=1
		#while [ $num -le $line ];
		#do
		#        pat0=` head -n $num $TMPFILEDDNS | tail -n 1`
		#        pat1=`echo $pat0 | cut -f1 -dS`
		#        pat2=`echo $pat1 | cut -f1 -d " "`
		#        kill -9 $pat2 2> /dev/null
		#
		#        num=`expr $num + 1`
		#done
		###########################
		#PIDFILE=/var/run/dnrd.pid
		#if [ -f $PIDFILE ] ; then
		#        killall -9 dnrd 2> /dev/null
		#        rm -f $PIDFILE
		#fi

		#kill igmpproxy before kill pppd
		#killall -9 igmpproxy 2> /dev/null

		#eval `flash get MULTI_PPP_MASTER`
		#typestr=`flash get PPP_CONNECT_TYPE_$MULTI_PPP_MASTER`
		#type=`echo $typestr | cut -f2 -d=`
		#if [ $type = 2 ]; then
		#if [ $type != 0 ]; then
		#	echo "---------------------------call firewall_pptp.sh $1 $2, in master_connect.sh--------------------------------------"
		#	firewall_pptp.sh $1 $2 $4
		#fi
		#sh -xv /bin/firewall_pptp.sh $1 $2 $4

	fi
else
	if [ $ENABLE = 1 ]; then
		/bin/superdmz_init.sh
		if [ -r "/bin/dns.sh" ]; then
			dns.sh 
		fi

		#upnp.sh
		if [ -f /bin/vpn.sh ]; then
		      echo 'Setup VPN'
		      vpn.sh all
		fi

		#restart igmpproxy
		eval `flash get IGMP_PROXY_DISABLED`
		killall -9 igmpproxy 2> /dev/null
		if [ $IGMP_PROXY_DISABLED = 0 ]; then
			igmpproxy $DEFAULT_ROUTE_IF br0 &
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
		#start firewall.sh
		#echo "-----------------------start firewall.sh for master pppoe-----------------------------------"
		$START_FIREWALL switch_to_pppoe $2
		/bin/route.sh add &

		#################################################################################################################
		#kill those program: ntp.sh, dnrd, ddns.sh, igmpproxy
		set_policy_routing.sh $2 $3 $5 1
	else

		killall -9 ntp.sh 2> /dev/null
		rm -f /var/ntp_run 2> /dev/null

		###########kill sleep that ntp.sh created###############
		TMPFILEDDNS=/tmp/tmpfileddns
		line=0
		ps | grep "sleep 86400" > $TMPFILEDDNS
		line=`cat $TMPFILEDDNS | wc -l`
		num=1
		while [ $num -le $line ];
		do
			pat0=` head -n $num $TMPFILEDDNS | tail -n 1`
			pat1=`echo $pat0 | cut -f1 -dS`
			pat2=`echo $pat1 | cut -f1 -d " "`
			kill -9 $pat2 2> /dev/null

			num=`expr $num + 1`
		done
		###########################
		
		#will set default route in other place in master mode, so only call this script when disconnecting
		/bin/set_default_route.sh &
		set_policy_routing.sh $2 $3 $5 0
	fi
fi

#if refresh firewall.sh cycle, must move it into firewall.sh
#if [ $1 = "connect" ]; then
#	`cat /etc/ppp/rst_firewall`
#fi
#echo "end of master_connect.sh---------------------------"
