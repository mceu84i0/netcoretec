#!/bin/sh

SYSLOGD_FILE=/tmp/syslogd_support

if [ -e $SYSLOGD_FILE ]; then
	eval `flash get REMOTELOG_ENABLED`
	if [ $REMOTELOG_ENABLED != "0" ]; then
		eval `flash get REMOTELOG_SERVER`
		tmp=`ps | grep syslogd`
		tmp=`echo $tmp | grep '[-]R'`
		if [ -n "$tmp" ]; then
			echo "syslogd is runnig with remote log server"
		else
			killall -9 syslogd
			syslogd -L -R $REMOTELOG_SERVER &
		fi
	fi
fi
