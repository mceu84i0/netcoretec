#!/bin/sh
SMBD_FILE=/var/samba/smb.conf
eval `flash get SAMBA_ENABLE`
if [ "$SAMBA_ENABLE" = "0" ];then
	#umount /var/sys
	killall smbd nmbd
	exit 0
fi

eval `flash get USER_NAME`
eval `flash get USER_PASSWORD`
eval `flash get SAMBA_ENCYPT`
eval `flash get SAMBA_USER`
eval `flash get SAMBA_PWD`

if [ "$1" = "initSMBCONF" ];then
	cp /etc/group /var/
	cp /bin/samba /var/ -r			
fi

#if [ "$1" = "modifySMBpasswd" ];then
#	echo "modifySMBpasswd"
#	smb.sh commSMB
#fi

if [ "$1" = "commSMB" ];then

		
	echo "$USER_NAME:$USER_PASSWORD:0:0:root:/:/bin/sh">/var/passwd
	echo "root::0:0:root:/:/bin/sh">> /var/passwd
	echo "nobody::0:0:root:/:/bin/sh">>/var/passwd
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
	echo "[global]" >$SMBD_FILE
        echo "	netbios name = Router" >>$SMBD_FILE
        echo "	workgroup = WORKGROUP" >>$SMBD_FILE
        echo "	log file = /var/smbd.log" >>$SMBD_FILE
	#echo "	log level = 5">>$SMBD_FILE
	#echo "	syslog = 0">>$SMBD_FILE
	echo "	max xmit = 65536">>$SMBD_FILE
	echo "	aio write size = 65536">>$SMBD_FILE
	echo "	aio read size = 65536">>$SMBD_FILE
	echo "	large readwrite = yes">>$SMBD_FILE
	echo "	getwd cache = yes">>$SMBD_FILE
	echo "	read raw = yes">>$SMBD_FILE
	echo "	write raw = yes">>$SMBD_FILE
	echo "	lpq cache = 30">>$SMBD_FILE
	echo "	oplocks = yes">>$SMBD_FILE
	echo "	winbind nested groups = no">>$SMBD_FILE
	echo "	domain master = no">>$SMBD_FILE
	echo "	local master = yes">>$SMBD_FILE
	echo "	local master = yes">>$SMBD_FILE
	echo "	public = yes">>$SMBD_FILE
	echo "	interfaces = br0" >>$SMBD_FILE
        echo "	dns proxy = no" >>$SMBD_FILE
       # echo "	encrypt passwords = yes" >> $SMBD_FILE
        echo "	socket options = IPTOS_LOWDELAY IPTOS_THROUGHPUT TCP_NODELAY SO_KEEPALIVE TCP_FASTACK SO_RCVBUF=65536 SO_SNDBUF=65536">> $SMBD_FILE
	echo "	getwd cache = yes">> $SMBD_FILE
	if [ $SAMBA_ENCYPT = 1 ]; then
	      echo "	security = user" >>$SMBD_FILE
	      echo "	passdb backend = smbpasswd">>$SMBD_FILE
	      echo "	smb password file = /etc/passwd">>$SMBD_FILE
	      echo "$SAMBA_USER:$SAMBA_PWD:0:0:root:/:/bin/sh">>/var/passwd
	      smbpasswd $SAMBA_USER $SAMBA_PWD
	else
	      echo "	security = share" >>$SMBD_FILE
	fi
        
	echo "[disk1_part1]" >>$SMBD_FILE
	echo "	path = "$PART1 >>$SMBD_FILE
	echo "	browseable = yes" >>$SMBD_FILE
	echo " 	read only = no" >>$SMBD_FILE
	echo "	public = yes">>$SMBD_FILE
	echo "	valid user = "$SAMBA_USER>>$SMBD_FILE	
	
	killall  smbd nmbd
	/bin/smbd -D
	/bin/nmbd -D
	exit 0

fi

