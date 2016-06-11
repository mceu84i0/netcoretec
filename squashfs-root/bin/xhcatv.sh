#! /bin/sh

eval `flash get XHCATV_ENABLED`
eval `flash get XHCATV_PASSWD`
eval `flash get XHCATV_NAME`
eval `flash get WAN_DHCP`

if [ $WAN_DHCP = 1 -a $XHCATV_ENABLED = 1 ]; then
	echo $XHCATV_NAME > /var/userid.txt	
	echo $XHCATV_PASSWD > /var/pw.txt
	/bin/xhcatv &
fi
