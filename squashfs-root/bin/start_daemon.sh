#! /bin/sh

generate_passwd.sh &
generate_inet_conf.sh

#telnetd &
#igdmptd &
#/bin/cdrom_wizard &

eval `flash get SUPER_NAME`
eval `flash get SUPER_PASSWORD`
eval `flash get USER_NAME`
eval `flash get USER_PASSWORD`
echo "${USER_NAME}:${USER_PASSWORD}" > /tmp/passwd
echo "${SUPER_NAME}:${SUPER_PASSWORD}" >> /tmp/passwd


# start web server
#webs&

#/bin/restart_webs &
#/bin/restart_oray &
#/bin/wps_detect &

/bin/loop_daemon &
/usr/sbin/inetd /var/inetd.conf &
