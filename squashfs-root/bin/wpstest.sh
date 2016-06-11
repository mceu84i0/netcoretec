#/bin/sh
while [ true ];
do
	VAL=`cat /proc/gpio`
	if [ $VAL = 1 ]; then
		flash set WLAN0_WSC_DISABLE 0
		/bin/init.sh gw all
	fi
done &
