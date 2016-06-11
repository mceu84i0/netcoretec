#!/bin/sh
export PATH=/bin:/usr/bin:/sbin:/usr/sbin
#eval `flash get IP_ADDR`

#if [ $IP_ADDR = "0" ];then
#flash default
#fi
par=`envram get et0macaddr`
if [ $par != "null" ];then
	flash set HW_NIC0_ADDR $par
	nvram set et0macaddr=$par
fi

par=`envram get wan_macaddr`
if [ $par != "null" ];then
	flash set HW_NIC1_ADDR $par

fi
par=`envram get sb/1/macaddr`
if [ $par != "null" ];then
	flash set HW_WLAN0_WLAN_ADDR $par
	flash set WLAN0_WLAN_MAC_ADDR $par
	nvram set sb/1/macaddr=$par
	nvram set wl0_hwaddr=$par
fi
par=`envram get 0:macaddr`
if [ $par != "null" ];then
	flash set HW_WLAN1_WLAN_ADDR $par
	flash set WLAN1_WLAN_MAC_ADDR $par
	nvram set 0:macaddr=$par
	nvram set wl1_hwaddr=$par

fi
par=`envram get wl0.1_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN0_WLAN_ADDR1 $par
	flash set WLAN0_VAP0_WLAN_MAC_ADDR $par
	nvram set wl0.1_hwaddr=$par
fi
par=`envram get wl0.2_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN0_WLAN_ADDR2 $par
	flash set WLAN0_VAP1_WLAN_MAC_ADDR $par
	nvram set wl0.2_hwaddr=$par
fi
par=`envram get wl0.3_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN0_WLAN_ADDR3 $par
	flash set WLAN0_VAP2_WLAN_MAC_ADDR $par
	nvram set wl0.3_hwaddr=$par
fi
par=`envram get wl0.4_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN0_WLAN_ADDR4 $par
	flash set WLAN0_VAP3_WLAN_MAC_ADDR $par
	nvram set wl0.4_hwaddr=$par
fi
par=`envram get wl0.5_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN0_WLAN_ADDR5 $par
	flash set WLAN0_VAP4_WLAN_MAC_ADDR $par
	nvram set wl0.5_hwaddr=$par
fi
par=`envram get wl0.6_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN0_WLAN_ADDR6 $par
	flash set WLAN0_VAP5_WLAN_MAC_ADDR $par
	nvram set wl0.6_hwaddr=$par
fi

par=`envram get wl1.1_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN1_WLAN_ADDR1 $par
	flash set WLAN1_VAP0_WLAN_MAC_ADDR $par
	nvram set wl1.1_hwaddr=$par
fi
par=`envram get wl1.2_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN1_WLAN_ADDR2 $par
	flash set WLAN1_VAP1_WLAN_MAC_ADDR $par
	nvram set wl1.2_hwaddr=$par
fi
par=`envram get wl1.3_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN1_WLAN_ADDR3 $par
	flash set WLAN1_VAP2_WLAN_MAC_ADDR $par
	nvram set wl1.3_hwaddr=$par
fi
par=`envram get wl1.4_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN1_WLAN_ADDR4 $par
	flash set WLAN1_VAP3_WLAN_MAC_ADDR $par
	nvram set wl1.4_hwaddr=$par
fi
par=`envram get wl1.5_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN1_WLAN_ADDR5 $par
	flash set WLAN1_VAP4_WLAN_MAC_ADDR $par
	nvram set wl1.5_hwaddr=$par
fi
par=`envram get wl1.6_hwaddr`
if [ $par != "null" ];then
	flash set HW_WLAN1_WLAN_ADDR6 $par
	flash set WLAN1_VAP5_WLAN_MAC_ADDR $par
	nvram set wl1.6_hwaddr=$par
fi

par=`envram get wl0_region`
if [ $par != "null" ];then
	flash set WLAN0_DOMAIN $par

fi
par=`envram get wl1_region`
if [ $par != "null" ];then
	flash set WLAN1_DOMAIN $par

fi
par=`envram get wl0_def_ssid`
if [ $par != "null" ];then
	flash set WLAN0_SSID $par

fi
par=`envram get wl1_def_ssid`
if [ $par != "null" ];then
	flash set WLAN1_SSID $par

fi
par=`envram get wl0.1_def_ssid`
if [ $par != "null" ];then
	flash set WLAN0_VAP0_SSID $par

fi
par=`envram get wl1.1_def_ssid`
if [ $par != "null" ];then
	flash set WLAN1_VAP0_SSID $par

fi
par=`envram get mimotype`
if [ $par != "null" ];then
	nvram set mimotype=$par
fi
par=`envram get version`
if [ $par != "null" ];then
	nvram set version=$par
fi

nvram commit
