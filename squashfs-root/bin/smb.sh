#!/bin/sh
SMBD_FILE=/var/samba.conf
eval `flash get SAMBA_ENABLE`
if [ "$SAMBA_ENABLE" = "0" ];then
	#umount /var/sys
	exit 0
fi


eval `flash get USER_NAME`
eval `flash get USER_PASSWORD`

if [ "$1" = "initSMBCONF" ];then
	echo "initSMBCONF" >$SMBD_FILE


	cd /
	/bin/smbpasswd -a $USER_NAME -p $USER_PASSWORD -c $SMBD_FILE
fi

if [ "$1" = "modifySMBpasswd" ];then
	killall smbd
	cd /
	/bin/smbpasswd -x $USER_NAME -c $SMBD_FILE
	/bin/smb.sh initSMBCONF
	/bin/smb.sh commSMB
fi

if [ "$1" = "commSMB" ];then
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
        killall smbd
        echo "[global]" >$SMBD_FILE
        echo "	netbios name = BeeLine" >>$SMBD_FILE
        echo "	workgroup = WORKGROUP" >>$SMBD_FILE
        echo "	log file = /var/smbd.log" >>$SMBD_FILE
        echo "	dns proxy = no" >>$SMBD_FILE
        echo "	security = user" >>$SMBD_FILE
	echo "	passdb backend = smbpasswd">>$SMBD_FILE
	echo "	smb password file = /var/password">>$SMBD_FILE
	echo "	client lanman auth = yes">>$SMBD_FILE
	echo "	client NTLMv2 auth = no">>$SMBD_FILE
	echo "[Beeline]" >>$SMBD_FILE
	echo "	path = "$PART1 >>$SMBD_FILE
	echo "	browseable = yes" >>$SMBD_FILE
	echo " 	read only = no" >>$SMBD_FILE
	echo "	public = yes">>$SMBD_FILE
	echo "	valid user = "$USER_NAME>>$SMBD_FILE
 	echo "root::0:0:root:/:/bin/sh">> /var/passwd
	echo "nobody::0:0:root:/:/bin/sh">>/var/passwd
	cp /var/passwd /var/password
	/bin/smbd -F -s /var/samba.conf &

	exit 0

fi

