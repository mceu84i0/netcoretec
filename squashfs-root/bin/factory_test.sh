#!/bin/sh
#
#  for 8196b factory test
#

mkdir /tmp/test
mount -t squashfs /dev/mtdblock1 /tmp/test/
cp /tmp/test/web/version.txt /tmp/version


#echo -ne "\n" >>/tmp/version
#cat /web/version.txt >>/tmp/version
