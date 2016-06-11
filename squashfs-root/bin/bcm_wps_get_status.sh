#!/bin/sh
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
#eval `flash get IP_ADDR`

par=`nvram get wps_proc_status`
echo $par > /tmp/wps_status
if [ $par = "2" ];then
	flash bcm_wps_success_reset_sec
fi


