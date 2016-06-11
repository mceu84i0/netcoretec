#!/bin/sh




while true
do


_mac_num=12

_mac_list=`/bin/cmac $_mac_num`


echo $_mac

_mac=`echo $_mac_list | cut -d' ' -f1`

echo $_mac
echo $_mac_list

if [ "$_mac" = "Change" ];then
	echo "hello"
elif [ "$_mac" != "" ];then
   flash set HW_NIC1_ADDR $_mac
	break;
fi

done

echo "Get mac from pc :" $_mac


_default_mac=`flash get HW_NIC1_ADDR | cut -d '=' -f 2-`

_mac_table=`/bin/cmac gen $_default_mac $_mac_num`

i=0
for _mac in $_mac_table
do
	_seg1=`echo $_mac | cut -c1-2`
	_seg2=`echo $_mac | cut -c3-4`
	_seg3=`echo $_mac | cut -c5-6`
	_seg4=`echo $_mac | cut -c7-8`
	_seg5=`echo $_mac | cut -c9-10`
        _seg6=`echo $_mac | cut -c11-12`
        Lan_mac="$_seg1:$_seg2:$_seg3:$_seg4:$_seg5:$_seg6"
        Wan_mac="$_seg1:$_seg2:$_seg3:$_seg4:$_seg5:$_seg6"
        if [ $i -eq 0 ];then
		echo "Lan setting ..."
        	ifconfig eth0 down
        	ifconfig eth0 hw ether "$Lan_mac"
        	flash set HW_NIC0_ADDR "$_mac"
        	flash set HW_WLAN_ADDR $_mac
		flash set HW_WLAN0_WLAN_ADDR $_mac
		flash set HW_WLAN_ADDR1 $_mac
		flash set HW_WLAN_ADDR2 $_mac
		flash set HW_WLAN_ADDR3 $_mac
		flash set HW_WLAN_ADDR4 $_mac
		flash set HW_WLAN_ADDR5 $_mac
		flash set HW_WLAN_ADDR6 $_mac
		flash set HW_WLAN_ADDR7 $_mac
		ifconfig eth0 up

        fi
	if [ $i -eq 1 ];then
		echo "Wan setting ..."
		ifconfig eth1 down
		ifconfig eth1 hw ether "$Wan_mac"
		flash set HW_NIC1_ADDR "$_mac"
       		ifconfig eth1 up
	fi
	
	if [ $i -eq 2 ];then
	 	flash set HW_WLAN_ADDR1 $_mac
	fi
      	if [ $i -eq 3 ];then
                flash set HW_WLAN_ADDR2 $_mac
        fi	

        if [ $i -eq 4 ];then
                flash set HW_WLAN_ADDR3 $_mac
        fi
	
        if [ $i -eq 5 ];then
                flash set HW_WLAN_ADDR4 $_mac
        fi

        if [ $i -eq 6 ];then
                flash set HW_WLAN_ADDR5 $_mac
        fi


        if [ $i -eq 7 ];then
                flash set HW_WLAN_ADDR6 $_mac
        fi

        if [ $i -eq 8 ];then
                flash set HW_WLAN_ADDR7 $_mac
        fi

	i=`expr $i + 1`
done

