#!/bin/sh

if [ $# -lt 1 ]; then 
	#echo "Usage: $0 {init}"; 
	exit 1 ; 
fi

if [ $1 != 'init' ]; then 
	#echo "Usage: $0 {init}"; 
	exit 1 ; 
fi

BRIDGE_INTERFACE=br0
IGD_PID_FILE=/var/run/miniupnpd.pid
eval `flash get UPNP_ENABLED`

killall -9 miniigd 2> /dev/null

# start mini_upnpd shared daemon
killall -9 mini_upnpd 2> /dev/null

eval `flash get WSC_DISABLE`

_CMD=
if [ $WSC_DISABLE = 0 ]; then
	_CMD="$_CMD -wsc /tmp/wscd_config"
fi

if [ $UPNP_ENABLED = 1 ]; then
		_CMD="$_CMD -igd /tmp/igd_config"
fi
	
if [ "$_CMD" != "" ]; then
	mini_upnpd $_CMD &
fi	

if [ -e "$IGD_PID_FILE" ]; then
	rm -f $IGD_PID_FILE
fi


PPP_NAME=ppp4

#iptables -t nat -F MINIUPNPD
#iptables -t nat -X MINIUPNPD
iptables -t filter -F MINIUPNPD
iptables -t filter -X MINIUPNPD
route del -net 239.255.255.250 netmask 255.255.255.255 br0
		
if [ $UPNP_ENABLED = 1 ]; then 
		
  	route add -net 239.255.255.250 netmask 255.255.255.255 br0
  	
  	iptables -I INPUT 1 -i $BRIDGE_INTERFACE -p TCP --dport 49152 -j ACCEPT
  	#iptables -t nat -N MINIUPNPD
   	iptables -t filter -N MINIUPNPD
   	
  	LINE=`ifconfig $BRIDGE_INTERFACE | grep "inet addr"`
  	LINE1=`echo "$LINE" | cut -f2 -d:`
  	IP_ADDR=`echo "$LINE1" | cut -f1 -d" "`
  	
  	NUM=0
		if [ -f /var/ppp/ppp_status ]; then
			AA=`cat /var/ppp/ppp_status`
			for LINE in $AA
			do
				PPP_NAME=`echo $LINE | cut -f1 -d,`
				
				EXT_IP0=`ifconfig $PPP_NAME | grep -i "addr:"`
				EXT_IP1=`echo $EXT_IP0 | cut -f2 -d:`
				EXT_IP=`echo $EXT_IP1 | cut -f1 -d " "`
				
				#iptables -t nat -A PREROUTING -d $EXT_IP -i $PPP_NAME -j MINIUPNPD
	  		iptables -t filter -A FORWARD -i $PPP_NAME -o ! $PPP_NAME -j MINIUPNPD
	  		
	  		WAN="$WAN -i $PPP_NAME"
	  		NUM=`expr $NUM + 1`
			done
		fi
  	
  	if [ $NUM -lt 1 ]; then
  		WAN="-i $PPP_NAME"
  		iptables -t nat -A PREROUTING -d 255.255.255.255 -i $PPP_NAME -j MINIUPNPD
	  	iptables -t filter -A FORWARD -i $PPP_NAME -o ! $PPP_NAME -j MINIUPNPD
  	fi
		miniigd $WAN -a $IP_ADDR -p 49152
fi


