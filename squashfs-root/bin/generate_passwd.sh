#! /bin/sh

eval `flash get USER_NAME`
eval `flash get USER_PASSWORD`
eval `flash get TELNETD_USER`
eval `flash get	TELNETD_PASSWD`
eval `flash get SUPER_NAME`
eval `flash get SUPER_PASSWORD`
eval `flash get SKY_USER_NAME`
eval `flash get SKY_USER_PASSWORD`
passwd_of_telnetd=/var/passwd.telnetd
src_passwd=/var/passwd

#if [ "$TELNETD_USER" = "0" -o "$TELNETD_USER" = "" ];then
if [ "$TELNETD_USER" = "0" ];then
    if [ "$SKY_USER_NAME" != "0" ];then
		echo "$SKY_USER_NAME:$SKY_USER_PASSWORD:0:0:root:/:/bin/sh" > $passwd_of_telnetd
	else
		echo "$USER_NAME:$USER_PASSWORD:0:0:root:/:/bin/sh" > $passwd_of_telnetd
	fi	
	#if done: ln -s $passwd_of_telnetd $RAMFSDIR/etc
	#if [ "$USER_NAME" != "root" -a "$SUPER_NAME" != "root" ]; then
	#if [ "$USER_NAME" != "root" ]; then
	#	echo "root:abSQTPcIskFGc:0:0:root:/:/bin/sh" >> $passwd_of_telnetd
	#fi
else
	echo "$TELNETD_USER:$TELNETD_PASSWD:0:0:root:/:/bin/sh" > $passwd_of_telnetd
	#notice: TELNETD_USER vs USER_NAME: not equal
	#if done: ln -s $passwd_of_telnetd $RAMFSDIR/etc
	#echo "$USER_NAME:$USER_PASSWORD:0:0:root:/:/bin/sh" >> $passwd_of_telnetd
	#if [ "$TELNETD_USER" != "root" -a "$USER_NAME" != "root" -a "$SUPER_NAME" != "root" ]; then
	#if [ "$TELNETD_USER" != "root" ]; then
	#	echo "root:abSQTPcIskFGc:0:0:root:/:/bin/sh" >> $passwd_of_telnetd
	#fi
fi

echo "netcore:netcore:0:0:root:/:/bin/sh" >> $passwd_of_telnetd
if [ ! -e $src_passwd ]; then
	cp $passwd_of_telnetd $src_passwd
fi

#notice: SUPER_NAME can't be 0!!!
#if [ "$SUPER_NAME" != "0" ]; then
#fi
