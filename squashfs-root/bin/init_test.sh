#!/bin/sh

echo 'factory test'
. /bin/factory_test.sh

ifconfig eth0 hw ether 001122334455
wlan.sh
brctl addbr br0
brctl stp br0 off
brctl setfd br0 0
brctl addif br0 eth0
brctl addif br0 wlan0
ifconfig eth0 up
ifconfig wlan0 up
ifconfig br0 192.168.1.1
ifconfig eth1 192.168.2.1


