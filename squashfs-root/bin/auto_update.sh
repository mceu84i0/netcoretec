#!/bin/sh

cmd="url_upgrade http://192.168.100.100"
#cmd="url_upgrade http://192.168.10.55"

sleep 15
$cmd &

DAY_OLD=""
while [ 1 ]
do
	sleep 60
	DAY=`date "+%d"`
	HOUR=`date "+%H"`
	if [ "$DAY" != "$DAY_OLD" -a "$HOUR" = "05" ];then
		$cmd &
		DAY_OLD="$DAY"
	fi
done
