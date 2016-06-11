#!/bin/sh
FTPD_FILE=/var/stupid-ftpd.conf
PART1=""
eval `flash get WEBHARD_ENABLED`
if [ "$WEBHARD_ENABLED" = "0" ];then
	umount /var/sys
	exit 0
fi
eval `flash get WEBHARD_USERNAME`
eval `flash get WEBHARD_PASSWORD`

if [ "$1" = "webhard" ];then

	if [ -e "/bin/web_hard" ];then
        	WEBHARD_RUN=`ps | grep "web_hard"`
        	if [ "$WEBHARD_RUN" = "" ];then
                	echo "run web_hard ....."
                	/bin/web_hard &
        	else
                	echo "already run webhard ,it 's ok ...."
        	fi
	fi
fi






if [ "$1" = "commftp" ];then
        PART1=""

        for part in a b c d e f g h i j k l m n o p q r s t u v w x y z
        do
                for index in 1 2 3 4 5 6 7 8 9
                do
                        if [ -e "/var/sd$part$index" ];then
                                PART1="/var/sd$part$index"_dir
                                MOUNT_DISK=`cat /proc/mounts |grep "$PART1"`
                                if [ "$MOUNT_DISK" != "" ];then
                                        break;
                                fi
                        fi
                done
                if [ "$PART1" != "" ]; then
                        break;
                fi
        done
        killall stupid-ftpd
        echo "mode=demon" >$FTPD_FILE
        echo "serverroot=/bin/stupid-ftpd" >>$FTPD_FILE
        echo "changeroottype=real" >>$FTPD_FILE
        echo "maxusers=2" >>$FTPD_FILE
        echo "log=/var/ftp_log" >>$FTPD_FILE
        echo "login-timeout=30" >>$FTPD_FILE
        echo "timeout=3000" >>$FTPD_FILE
        echo "banmsg=Go away !" >>$FTPD_FILE
        #eval `flash get WEBHARD_FTPPORT`
        if [ -e "$PART1" ];then
                eval `flash get USER_NAME`
		eval `flash get USER_PASSWRD`
                /bin/stupid-ftpd-common.sh "21" 9 300 300
                /bin/stupid-ftpd-user.sh "$USER_NAME" "$USER_PASSWORD" "$PART1" 9 A
                /bin/stupid-ftpd -f "$FTPD_FILE"
        fi
        exit 0


fi

if [ "$1" = "ftp" ];then
#	CHECK_MOUNTS=""
#	while [ "$CHECK_MOUNTS" = "" ]
#	do
#       	CHECK_MOUNTS=`cat /proc/mounts | grep "media"`
#        	if [ "$CHECK_MOUNTS" != "" ];then
#           		break;
#        	fi
#		sleep 3
#	done




        PART1=""

        for part in a b c d e f g h i j k l m n o p q r s t u v w x y z
        do
                for index in 1 2 3 4 5 6 7 8 9
                do
                        if [ -e "/media/sd$part$index" ];then
                                PART1="/media/sd$part$index"_dir
                                MOUNT_DISK=`cat /proc/mounts |grep "$PART1"`
                                if [ "$MOUNT_DISK" != "" ];then
                                        break;
                                fi
                        fi
                done
                if [ "$PART1" != "" ]; then
                        break;
                fi
        done


	killall stupid-ftpd
	echo "mode=demon" >$FTPD_FILE
	echo "serverroot=/bin/stupid-ftpd" >>$FTPD_FILE
	echo "changeroottype=real" >>$FTPD_FILE
	echo "maxusers=2" >>$FTPD_FILE
	echo "log=/var/ftp_log" >>$FTPD_FILE
	echo "login-timeout=30" >>$FTPD_FILE
	echo "timeout=3000" >>$FTPD_FILE
	echo "banmsg=Go away !" >>$FTPD_FILE
	eval `flash get WEBHARD_FTPPORT`
	if [ -e "$PART1" ];then
		OPATH="$PART1"
                EPPATH="$OPATH/epvol"
		mkdir -p  "$EPPATH"
		chmod 777 "$EPPATH"
		mkdir -p  "$EPPATH/GDrive"
		chmod 777 "$EPPATH/GDrive"
		mkdir -p  "$EPPATH/FDrive"
		chmod 777 "$EPPATH/FDrive"	
		/bin/stupid-ftpd-common.sh "$WEBHARD_FTPPORT" 9 300 300
        	/bin/stupid-ftpd-user.sh "$WEBHARD_USERNAME" "$WEBHARD_PASSWORD" "$OPATH" 9 A
		/bin/stupid-ftpd -f "$FTPD_FILE"
	fi 
	exit 0
fi


if [ "$1" = "mount" ];then
	#killall udp_mount
         if [ -e "/bin/udp_mount" ];then
		UDP_MOUNT=`ps | grep "udp_mount"`
		echo "ps result:" $UDP_MOUNT
		if [ "$UDP_MOUNT" = "" ];then
			/bin/udp_mount &
			sleep 1	
		else
			echo " already run udp_mount,it 's ok ...."
		fi
	fi
	/bin/mount -t sysfs none /sys
	echo "/bin/igd_hotplug" > /proc/sys/kernel/hotplug
	exit 0
fi

if [ "$1" = "kill-unmount" ];then
	/bin/checkmount.sh
	exit 0
fi
