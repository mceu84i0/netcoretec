#!/bin/sh


PART1=""

for part in a b c d e f g h i j k l m n o p q r s t u v w x y z
	do
        	for index in 1 2 3 4 5 6 7 8 9
                do
                        if [ -e "/media/sd$part$index" ];then
                                PART1="/media/sd$part$index"_dir
                                /bin/umount $PART1
                        fi
                done
                if [ "$PART1" != "" ]; then
                        break;
                fi
        done


#killall udp_mount
killall stupid-ftpd
#/bin/umount /var/sys
killall web_hard
killall ntfs-3g
