#!/bin/sh
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
dates=$1
times=$2
date_enable=0
if [ "$dates" != "all" ];then 
	for da in $dates ; do
		week1=`date | cut -d' ' -f1`
		if [ $da = $week1 ]; then 
			date_enable=1
			break
		fi
	done
elif [ "$dates" = "all" ] ;then
	date_enable=1
fi

if [ $date_enable = 1 ] ;then
	if [ "$times" != "all" ]; then 
		time1=`echo $times | cut -d- -f1`
		time2=`echo $times | cut -d- -f2`
		hour1=`echo $time1 | cut -d: -f1`
		secend1=`echo $time1 | cut -d: -f2`
		hour2=`echo $time2 | cut -d: -f1`
                secend2=`echo $time2 | cut -d: -f2`
		test_num=`date | cut -d' ' -f3`
		if [ $test_num ] ; then 
			date_time=`date | cut -d' ' -f4`
		else
			date_time=`date | cut -d' ' -f5`
		fi
		rhour=`echo $date_time | cut -d: -f1`
		rsecend=`echo $date_time | cut -d: -f2`
		if [ $hour2 -eq $hour1 ] && [ $secend2 -le $secend1 ] || [ $hour2 -lt $hour1 ]; then
			if [ $rhour -gt $hour1 ] && [ $rhour -le 23 ];then 
				echo 1
			elif [ $rhour -lt $hour2 ] && [ $rhour -ge 00 ]; then
				echo 1
			elif [ $rhour -eq $hour1 ] && [ $rsecend -ge $secend1 ]; then
                                echo 1
			elif [ $rhour -eq $hour2 ] && [ $rsecend -le $secend1 ]; then
                                echo 1
			else
				echo 0
			fi
		elif [ $rhour -gt $hour1 ] && [ $rhour -lt $hour2 ]
		then
			echo 1
		elif [ $rhour -eq $hour1 ]&& [ $rsecend -ge $secend1 ] && [ $rhour -le $hour2 ]
		then
			echo 1
		elif [ $rhour -eq $hour2 ]&& [ $rsecend -lt $secend2 ]
                then
                        echo 1
		else
			echo 0
		fi

	else
		echo 1
	fi

else
	echo 0

fi

