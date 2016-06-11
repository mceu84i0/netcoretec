#!/bin/sh

eval `flash get TRIGGERPORT_ENABLED`

case $1 in
	init)
		if [ "$2" != "" ];then
			/web/cgi-bin/cgitest.cgi port_trigger $2
		else
			echo "port trigger: error get wan name."
		fi
		echo "port trigger init, wan is $2."
		;;
	start)
		if [ "$TRIGGERPORT_ENABLED" = "1" ];then
			/web/cgi-bin/cgitest.cgi port_trigger
		fi
		echo "port trigger start."
		;;
	stop)
		/web/cgi-bin/cgitest.cgi port_trigger delall
		echo "port trigger stop."
		;;
	restar)
		$0 stop
		$0 start
		;;
	*)
		echo "useage: port_trigger.sh start|stop|restart"
		;;
esac

exit
