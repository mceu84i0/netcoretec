#!/bin/sh

echo "Change bonding to " $1

flash set WLAN0_CHANNEL_BONDING  $1
flash set_mib wlan0
ifconfig wlan0 up

exit 0
