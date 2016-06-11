#!/bin/sh

par_val=$1
ACT=$2
apps=$3

CMD=

APPS=`echo $apps | cut -f1 -d'|'`
if [ "$APPS" = "" ];then
	exit
fi

i=1
while [ "$APPS" != "" ]
do
	echo APPS:$APPS
	case $APPS in
		www)
			iptables -A ip_filter -p TCP $par_val -m multiport --dport 80,3128,8000,8080,8081 -j $ACT
			;;
		e_mail_sending)
			iptables -A ip_filter -p TCP $par_val --dport 25 -j $ACT
			;;
		news_forums)
			iptables -A ip_filter -p TCP $par_val --dport 119 -j $ACT
			;;
		e_mail_receiving)
			iptables -A ip_filter -p TCP $par_val --dport 110 -j $ACT
			;;
		secure_http)
			iptables -A ip_filter -p TCP $par_val --dport 443 -j $ACT
			;;
		file_transfer)
			iptables -A ip_filter -p TCP $par_val --dport 21 -j $ACT
			;;
		msn_messenger)
			iptables -A ip_filter -p TCP $par_val --dport 1863 -j $ACT
			;;
		telnet_service)
			iptables -A ip_filter -p TCP $par_val --dport 23 -j $ACT
			;;
		aim)
			iptables -A ip_filter -p TCP $par_val --dport 5190 -j $ACT
			;;
		netmeeting)
			iptables -A ip_filter -p TCP $par_val -m multiport --dport 389,522,1503,1720,1731 -j $ACT
			;;
		dns)
			iptables -A ip_filter -p UDP $par_val --dport 53 -j $ACT
			;;
		snmp)
			iptables -A ip_filter -p UDP $par_val -m multiport --dport 161,162 -j $ACT
			;;
		vpn_pptp)
			iptables -A ip_filter -p TCP $par_val --dport 1723 -j $ACT
			;;
		vpn_l2tp)
			iptables -A ip_filter -p UDP $par_val --dport 1701 -j $ACT
			;;
		all_tcp_port)
			iptables -A ip_filter -p TCP $par_val -j $ACT
			;;
		all_udp_port)
			iptables -A ip_filter -p UDP $par_val -j $ACT
			;;
		*)
			echo "no app:$APPS"
			exit
			;;
	esac
	i=`expr $i + 1`
	APPS=`echo $apps | cut -f$i -d'|'`
done
