#!/bin/sh
FTPD_FILE=/var/stupid-ftpd.conf
PART1=""


eval `flash get USER_NAME`
eval `flash get USER_PASSWORD`

if [ "$1" = "commftp" ];then

	eval `flash get FTP_SERVER_ENABLE`
	if [ "$FTP_SERVER_ENABLE" = "0" ];then
		#umount /var/sys
		killall stupid-ftpd
		exit 0
	fi

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
	if [ "$PART1" = "" ]; then
               exit 0		
        fi
        killall stupid-ftpd
        #echo "mode=demon" >$FTPD_FILE
        #echo "serverroot=/bin/stupid-ftpd" >>$FTPD_FILE
        #echo "changeroottype=real" >>$FTPD_FILE
        #echo "maxusers=2" >>$FTPD_FILE
        #echo "log=/var/ftp_log" >>$FTPD_FILE
        #echo "login-timeout=30" >>$FTPD_FILE
        #echo "timeout=3000" >>$FTPD_FILE
        #echo "banmsg=Go away !" >>$FTPD_FILE
        #eval `flash get WEBHARD_FTPPORT`
       # if [ -e "$PART1" ];then
	/bin/stupid-ftpd-common.sh 21 9 300 300
	/bin/stupid-ftpd-user.sh "$PART1" 9 A
	/bin/stupid-ftpd -f "$FTPD_FILE"
        #fi
        exit 0


fi


if [ "$1" = "mount" ];then
	#killall udp_mount
        /bin/mount -t sysfs none /sys
        echo "/bin/igd_hotplug" > /proc/sys/kernel/hotplug
         if [ -e "/bin/udp_mount" ];then
		killall udp_mount
		udp_mount &
		echo " already run udp_mount,it 's ok ...."
	fi
	exit 0
fi

if [ "$1" = "kill-unmount" ];then
	/bin/checkmount.sh
	exit 0
fi
