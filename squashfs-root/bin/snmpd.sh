#!/bin/sh

if [ "$#" != "1" ]; then echo "Usage: $0 {start | stop | restart}"; exit 1 ; fi

RETVAL=0
GETMIB="flash get"
CONFILE=/var/run/snmpd.conf
PIDFILE=/var/run/snmpd.pid

eval `$GETMIB SNMP_IP_FORWARD`
eval `$GETMIB SNMP_IP_DEFAULT_TTL`
echo "$SNMP_IP_FORWARD" > /proc/sys/net/ipv4/ip_forward
echo "$SNMP_IP_DEFAULT_TTL" > /proc/sys/net/ipv4/ip_default_ttl 

eval `$GETMIB SNMP_IF_LO`
eval `$GETMIB SNMP_IF_BR0`
eval `$GETMIB SNMP_IF_ETH0`
eval `$GETMIB SNMP_IF_ETH1`
eval `$GETMIB SNMP_IF_ETH2`
eval `$GETMIB SNMP_IF_ETH3`
eval `$GETMIB SNMP_IF_ETH4`
eval `$GETMIB SNMP_IF_WLAN0`
eval `$GETMIB SNMP_IF_WLAN0_VA2`
ifconfig lo "$SNMP_IF_LO"
ifconfig br0 "$SNMP_IF_BR0" 
ifconfig eth0 "$SNMP_IF_ETH0" 
ifconfig eth1 "$SNMP_IF_ETH1"
ifconfig eth2 "$SNMP_IF_ETH2"
ifconfig eth3 "$SNMP_IF_ETH3"
ifconfig eth4 "$SNMP_IF_ETH4"
ifconfig wlan0 "$SNMP_IF_WLAN0"
ifconfig wlan0-va2 "$SNMP_IF_WLAN0_VA2"


if [ $1 = "stop" ]; then
	# Stop snmpd.
	if [ -f $PIDFILE ]; then
		PID=`cat $PIDFILE`
		if [ $PID != 0 ]; then
			kill -9 $PID
			RETVAL=$?
			if [ $RETVAL = 0 ]; then 
				echo "Shutting down snmpd ... Success"
			else    
				echo "Shutting down snmpd ... Fail"
			fi    
		fi
		rm -f $PIDFILE
	else
		echo "Shutting down snmpd ... No snmpd running"	
	fi
fi

if [ $1 = "start" -a -f $PIDFILE ]; then
	echo "Starting snmpd ... Already running"
	exit 1
fi	

if [ $1 = "start" -o $1 = "restart" ]; then
	# Start snmpd.
	eval `$GETMIB SNMP_ENABLED`
	eval `$GETMIB SNMP_NAME`
	eval `$GETMIB SNMP_LOCATION`
	eval `$GETMIB SNMP_CONTACT`
	#eval `$GETMIB SNMP_RWCOMMUNITY`
	#eval `$GETMIB SNMP_ROCOMMUNITY`
	#eval `$GETMIB SNMP_TRAP_RECEIVER1`
	#eval `$GETMIB SNMP_TRAP_RECEIVER2`
	#eval `$GETMIB SNMP_TRAP_RECEIVER3`

	if [ $SNMP_ENABLED = 1 ]; then
		echo "rocommunity  public" > $CONFILE
		echo "rwcommunity    YuanBLiuBTaoBSongBHuiB" >> $CONFILE
		echo 'createUser _internal MD5 "kratos210"' >> $CONFILE
		echo "rouser _internal" >> $CONFILE
		echo "iquerySecName _internal" >> $CONFILE
                echo "linkUpDownNotifications yes" >> $CONFILE
		#echo "sysContact  $SNMP_CONTACT" >> $CONFILE
		#echo "sysName  $SNMP_NAME" >> $CONFILE
		#echo "sysLocation  $SNMP_LOCATION" >> $CONFILE
		eval `$GETMIB SNMP_CON_TBL_NUM`
		num=1
  		while [ $num -le $SNMP_CON_TBL_NUM ];
  		do	
			SNMP_CON_TBL=`flash get SNMP_CON_TBL | grep SNMP_CON_TBL$num=`
    			tmp_addr=`echo $SNMP_CON_TBL | cut -f2 -d=`
    			community=`echo $tmp_addr | cut -f1 -d,`
    			Popedom=`echo $tmp_addr | cut -f2 -d,`
			if [ $Popedom = "0" ]; then 
				echo "rocommunity  $community" >> $CONFILE
			else
				echo "rwcommunity  $community" >> $CONFILE
			fi
			num=`expr $num + 1`
 		done
		eval `$GETMIB SNMP_TRAP_TBL_NUM`
                num=1
                while [ $num -le $SNMP_TRAP_TBL_NUM ];
                do
                        SNMP_TRAP_TBL=`flash get SNMP_TRAP_TBL | grep SNMP_TRAP_TBL$num=`
                        tmp_addr=`echo $SNMP_TRAP_TBL | cut -f2 -d=`
                        ip=`echo $tmp_addr | cut -f1 -d,`
                        Community=`echo $tmp_addr | cut -f2 -d,`
                        echo "trapsink  $ip $Community" >> $CONFILE
			num=`expr $num + 1`
                done

		echo "authtrapenable  1" >> $CONFILE
	fi
fi
if [ $1 = "start" ];then
	if [ $SNMP_ENABLED = 1 ]; then
		if [ "$DEBUG" = "1" ]; then
                        snmpd -d -Lo -C -c $CONFILE -p $PIDFILE
        	else
                        snmpd -Lf /dev/null -C -c $CONFILE -p $PIDFILE
        	fi
       		RETVAL=$?
        	if [ $RETVAL = 0 ]; then
                        echo "Starting snmpd ... Success"
        	else
                        echo "Starting snmpd ... Fail"
        	fi
	fi

fi
exit $RETVAL
