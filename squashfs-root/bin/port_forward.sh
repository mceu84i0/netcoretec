#!/bin/sh

WAN=$1
EXT_IP=$2

eval `flash get PORT_FORWARD_ENABLED`
eval `flash get PORT_FORWARD_NUM`

if [ "$PORT_FORWARD_ENABLED" = "1" ]; then
	num=1
	while [ $num -le $PORT_FORWARD_NUM ];
	do
		PORT_FORWARD_TBL=`flash get PORT_FORWARD_TBL | grep PORT_FORWARD_TBL$num=`
		port_forward_entry=`echo $PORT_FORWARD_TBL | cut -f2 -d=`
		host=`echo $port_forward_entry | cut -f1 -d,`
		protocol=`echo $port_forward_entry | cut -f2 -d,`
		port_start=`echo $port_forward_entry | cut -f3 -d,`
		port_end=`echo $port_forward_entry | cut -f4 -d,`

		if [ $protocol = 1 -o $protocol = 0 ]; then
                        iptables -A PREROUTING -t mangle -i $WAN -p TCP --dport $port_start:$port_end -d $EXT_IP -j MARK --set-mark 2
			iptables -A PREROUTING -t nat -p TCP --dport $port_start:$port_end -d $EXT_IP -j DNAT --to $host:$port_start-$port_end
		fi
		if [ $protocol = 2 -o $protocol = 0 ];then
                        iptables -A PREROUTING -t mangle -i $WAN -p UDP --dport $port_start:$port_end -d $EXT_IP -j MARK --set-mark 2
			iptables -A PREROUTING -t nat -p UDP --dport $port_start:$port_end -d $EXT_IP -j DNAT --to $host:$port_start-$port_end

		fi
		num=`expr $num + 1`
	done
fi
