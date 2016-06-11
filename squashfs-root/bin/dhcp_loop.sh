#!/bin/sh

#linxb@2011.03.15
#notice:	called by dhcp.bound script file, so not to judge WAN_DHCP
DHCP_LOOP_FILE=/tmp/.loop_file
RESOLV_CONF="/etc/udhcpc/resolv.conf"
#REAL_RESOLV_CONF="/etc/resolv.conf"
REAL_RESOLV_CONF="/var/resolv.conf"
TMP_RT_FILE="/tmp/default_rt"

if [ $# -lt 3 ]; then
	echo "error:	need three args, in $0!!!"
	exit 1
fi
ip=$1
interface=$2
subnet_ip=$3
eval `flash get IP_ADDR`
#if [ -e $TMP_RT_FILE ]; then
	dns_flag=0
	rt_flag=0
	#mid=`cat $TMP_RT_FILE`

	#for i in $mid
	#do
	#	if [ $i = $IP_ADDR ]; then
	#		flag=1
	#	fi
	#done
	#fixme: if br_ip and wan_ip are in the same net, should do:
	if [ -e $TMP_RT_FILE ]; then
		mid=`cat $TMP_RT_FILE`

		for i in $mid
		do
			if [ $i = $IP_ADDR ]; then
				rt_flag=1
			fi
		done
	fi

	#if [ $flag = 0 ] && [ -e $RESOLV_CONF ]; then
	if [ -e $RESOLV_CONF ]; then
		DNS="--cache=off"

		line=0
		cat $RESOLV_CONF | grep nameserver > /tmp/ddfile
		line=`cat /tmp/ddfile | wc -l`
		num=1
		while [ $num -le $line ];
		do
			pat0=` head -n $num /tmp/ddfile | tail -n 1`
			pat1=`echo $pat0 | cut -f2 -d " "`
			if [ $pat1 = $IP_ADDR ]; then
				dns_flag=1
			else
				DNS="$DNS -s $pat1"
			fi
			num=`expr $num + 1`
		done
		
		#if more than 1 dns, only delete it
		#if [ $dns_flag = 1 -a $line -gt 1 ]; then
		#	TMP=/tmp/.tmp
		#	dns_flag=2
		#
		#	rm -fr /var/run/dnrd.pid
		#	killall -9 dnrd
		#
		#	grep -v $IP_ADDR $RESOLV_CONF > $TMP
		#	rm -fr $RESOLV_CONF
		#	cp -fr $TMP $RESOLV_CONF
		#
		#	grep -v $IP_ADDR $REAL_RESOLV_CONF > $TMP
		#	rm -fr $REAL_RESOLV_CONF
		#	cp -fr $TMP $REAL_RESOLV_CONF
		#
		#	rm -fr $TMP
		#	
		#	dnrd $DNS
		#fi
	fi


	if [ $rt_flag = 1 ]; then
		if [ $# -eq 4 -a $4 != "255.255.255.255" ]; then
			#`flash get SUBNET_MASK`
			route del -net $subnet_ip netmask $4 dev $interface

			route -n > /tmp/xxx
			str=`grep $subnet_ip /tmp/xxx`
			str2=`echo $str | cut -f1 -d " "`
			if [ -z $str2 ]; then
				route add -net $subnet_ip netmask $4 dev br0
			fi
			rm -fr /tmp/xxx
		fi

		#add wan ip into dhcpd's static lease 
		eval `flash get WAN_MAC_ADDR`
		if [ $WAN_MAC_ADDR = "0" -o $WAN_MAC_ADDR = "000000000000" ]; then
			WAN_MAC_ADDR=000504030201
		fi
		echo "static_lease $WAN_MAC_ADDR $ip none" > /tmp/.loop_static_lease 
		#echo "add_static_lease" > /tmp/dhcpd_action
		#killall -SIGUSR2 udhcpd	
		killall -9 udhcpd 2> /dev/null
		rm -f /var/run/udhcpd.pid 2> /dev/null
		/bin/dhcpd.sh br0 gw

		###arp request of wan_ip, will not reply
		#if [ $dns_flag = 1 ]; then
			echo "1 $interface" > /proc/lan_arp

			ip route change $IP_ADDR dev $interface src $ip scope link table local		
			iptables -t nat -A PREROUTING -p ALL -d $IP_ADDR -i br0 -j DNAT --to $ip
			if [ $# -eq 4 -a $4 != "255.255.255.255" ]; then
				route del -net $subnet_ip netmask $4 dev $interface
			fi
			ip route flush cache

			echo "ip route del $IP_ADDR table local" > $DHCP_LOOP_FILE
			echo "ip route add to local $IP_ADDR dev br0 scope host table local" >> $DHCP_LOOP_FILE
			echo "iptables -t nat -D PREROUTING -p ALL -d $IP_ADDR -i br0 -j DNAT --to $ip" >> $DHCP_LOOP_FILE
			echo "echo 0 > /proc/lan_arp" >> $DHCP_LOOP_FILE
			eval `flash get NTP_SERVER_ENABLED`
			if [ $NTP_SERVER_ENABLED = 1 ]; then
				killall ntpd
				/bin/ntpd -c /etc/ntp.conf &
			fi
		#else
		#	#only send arp reply packet
		#	echo "3 $interface" > /proc/lan_arp
		#fi
	fi	
	if [ $dns_flag = 1 ]; then
		datastr=`date '+%b %d %X'`
		#echo "$datastr  (none) user.err udhcpc: no valid dns server address!, lan ip and the dns ip that is only one are the same" >> /var/log/messages
		echo "$datastr  (none) user.err udhcpc: lan ip and the dns ip are the same" >> /var/log/messages
	fi
#fi
