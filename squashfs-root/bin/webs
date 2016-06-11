#!/bin/sh

if [ $# -gt 0 ]; then 
	if [ $# -gt 1 ]; then 
		rm -fr /tmp/passwd
	fi
	flag=1
else
	flag=0
fi

if [ -e /tmp/passwd ];then 
	echo "/tmp/passwd is exist! not need to generate it"
else
	eval `flash get SUPER_NAME`
	eval `flash get SUPER_PASSWORD`
	eval `flash get USER_NAME`
	eval `flash get USER_PASSWORD`
	echo "${USER_NAME}:${USER_PASSWORD}" > /tmp/passwd
	echo "${SUPER_NAME}:${SUPER_PASSWORD}" >> /tmp/passwd
fi

if [ $flag = 0 ]; then
	/bin/boa -p /web -f /etc/boa.conf &
fi
