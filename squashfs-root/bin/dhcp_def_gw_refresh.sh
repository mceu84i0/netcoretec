#!/bin/sh

TMP_RT_FILE=/tmp/default_rt
eval `flash get WAN_DHCP`

if [ $WAN_DHCP = 13 ]; then
	if [ -e $TMP_RT_FILE ]; then
		mid=`cat $TMP_RT_FILE`

		for i in $mid
		do
			route del -net default gw $i
		done
	else
		echo "err: $TMP_RT_FILE is not exist"
	fi

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
		
		route add -net default gw $ptpgw dev $pppoe_name
	fi
fi
route del 0.0.0.0
