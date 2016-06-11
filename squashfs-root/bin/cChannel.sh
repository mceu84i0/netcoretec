#!/bin/sh

_channel=$1
if [ ! -z "$_channel" ];then
	flash set WLAN0_CHANNEL $_channel
	flash set_mib wlan0
	ifconfig wlan0 up
fi
exit 0
