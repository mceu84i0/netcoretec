#! /bin/sh

eval `flash get TELNETD_DISABLED`

if [ "$TELNETD_DISABLED" = "0" ]; then
	#generate_passwd.sh &
	generate_passwd.sh
	telnetd &
else
	killall -9 telnetd
fi
