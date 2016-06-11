#! /bin/sh

eval `flash get SMTP_SERVER`
eval `flash get SMTP_SEND_FROM`
eval `flash get SMTP_SEND_TO`
eval `flash get SMTP_PORT`
eval `flash get SMTP_AUTH`
eval `flash get SMTP_LOG_TYPE`
PACKET=0

rm -fr /tmp/maillog

if [ -n "$SMTP_SERVER" ] && [ -n "$SMTP_SEND_FROM" ] && [ -n "$SMTP_SEND_TO" ]; then
	DATE=`date`
	CMD="-t $SMTP_SEND_TO -smtp $SMTP_SERVER -port $SMTP_PORT -f $SMTP_SEND_FROM +cc +bc -v "

	killall -SIGUSR1 logd
	echo $CMD > /tmp/maillog

	if [ $SMTP_LOG_TYPE -eq 0 ]; then
		LOG="notice|debug|info|warn|err"
	else
		if [ $SMTP_LOG_TYPE -ge 16 ]; then
			#notice
			LOG="notice"
			SMTP_LOG_TYPE=`expr $SMTP_LOG_TYPE - 16`
		fi

		if [ $SMTP_LOG_TYPE -ge 8 ]; then
			#dropped packets
			PACKET=1
			if [ -n "$LOG" ]; then
				LOG="$LOG|packet"
			else
				LOG="packet"
			fi
			SMTP_LOG_TYPE=`expr $SMTP_LOG_TYPE - 8`
		fi

		if [ $SMTP_LOG_TYPE -ge 4 ]; then
			#attacks
			if [ -n "$LOG" ]; then
				LOG="$LOG|attack"
			else
				LOG="attack"
			fi
			SMTP_LOG_TYPE=`expr $SMTP_LOG_TYPE - 4`
		fi

		if [ $SMTP_LOG_TYPE -ge 2 ]; then
			#debug
			if [ -n "$LOG" ]; then
				LOG="$LOG|debug"
			else
				LOG="debug"
			fi
			SMTP_LOG_TYPE=`expr $SMTP_LOG_TYPE - 2`
		fi

		if [ $SMTP_LOG_TYPE -eq 1 ]; then
			#system activity
			if [ -n "$LOG" ]; then
				LOG="$LOG|info|err|warn"
			else
				LOG="info|err|warn"
			fi
			SMTP_LOG_TYPE=`expr $SMTP_LOG_TYPE - 1`
		fi
	fi
	
	echo $LOG > /tmp/logcmd

	cat /var/log/messages | grep -E "$LOG" > /tmp/log_msg
	
	if [ $PACKET -eq 1 ]; then 
		cat /proc/net/dev >> /tmp/log_msg
	fi
	
	if [ $SMTP_AUTH != 0 ]; then
		eval `flash get SMTP_ACCOUNT`
		eval `flash get SMTP_PASSWD`
		if [ -n "$SMTP_ACCOUNT" ]; then
			CMD="$CMD -auth-login -user $SMTP_ACCOUNT"
			/bin/mailsend $CMD -pass "$SMTP_PASSWD"  -sub "routerlog@$DATE" -M "router's log,$DATE"  -attach "/tmp/log_msg,text/xplain" -attack "/var/logs,text/xplain" 
		else
			echo "err: smtp account is null!!!" >> /tmp/maillog
			exit 1
		fi
	else
		/bin/mailsend $CMD -sub "routerlog@$DATE" -M "router's log,$DATE"  -attach "/tmp/log_msg,text/xplain" -attack "/var/logs,text/xplain" 
	fi
	
	echo $? >> /tmp/maillog
else
	echo "err: can't send email, need some argruments"
fi
