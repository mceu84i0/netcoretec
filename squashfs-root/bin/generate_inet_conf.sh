#! /bin/sh

#/etc/inetd.conf
#telnet	stream	tcp	nowait	root	/usr/sbin/telnetd telnetd
#igdmptd	dgram	udp	wait	root	/bin/igdmptd igdmptd --inetd
#cdrom_wizard	dgram	udp	wait	root	/bin/cdrom_wizard cdrom_wizard --inetd
inetd_conf=/var/inetd.conf

rm -Rf $inetd_conf

eval `flash get TELNETD_DISABLED`
if [ 1 = 0 ]; then
	eval `flash get SUPER_NAME`
	eval `flash get USER_NAME`
	eval `flash get TELNETD_USER`

	if [ "$TELNETD_DISABLED" = "0" ]; then
		if [ "$TELNETD_USER" = "0" ]; then
			tnam=$USER_NAME
		else
			tnam=$TELNETD_USER
		fi
		echo "telnet	stream	tcp	nowait	$tnam	/usr/sbin/telnetd telnetd" > $inetd_conf
	fi

	if [ "$USER_NAME" = "" ]; then
		inam=root
	else
		inam=$USER_NAME
	fi
	echo "igdmptd	dgram	udp	wait	$inam	/bin/igdmptd igdmptd --inetd" >> $inetd_conf
	echo "cdrom_wizard	dgram	udp	wait	$inam	/bin/cdrom_wizard cdrom_wizard --inetd" >> $inetd_conf

	#check root user name
	res=`cat /etc/passwd | grep "^root:"`
	if [ -z "$res" ]; then
		echo "root:abSQTPcIskFGc:0:0:root:/:/bin/sh" >> /etc/passwd
	fi
	res=`cat /etc/passwd | grep "^root:"`
	if [ -z "$res" ]; then
		echo "root:abSQTPcIskFGc:0:0:root:/:/bin/sh" >> /var/passwd
	fi
else
	if [ "$TELNETD_DISABLED" = "0" ]; then
		echo "telnet	stream	tcp	nowait	root	/usr/sbin/telnetd telnetd" > $inetd_conf
	fi

	echo "igdmptd	dgram	udp	wait	root	/bin/igdmptd igdmptd --inetd" >> $inetd_conf
	echo "cdrom_wizard	dgram	udp	wait	root	/bin/cdrom_wizard cdrom_wizard --inetd" >> $inetd_conf
fi
