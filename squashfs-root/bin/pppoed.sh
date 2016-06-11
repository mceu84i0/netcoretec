#!/bin/sh
#WAN=eth1
echo "********************************exec pppoed.sh********************"
eval `flash get PPPOED_ENABLE`

killall pppoe-server
if [ $PPPOED_ENABLE -gt 0 ]; then
	flash gen-pppoed /etc/ppp/pool_remote_pppoe /etc/ppp/pppoe-server-options /etc/ppp/chap-secrets
	eval `flash get PPPOED_LOCAL`
	sleep 2
	pppoe-server -L $PPPOED_LOCAL -p /etc/ppp/pool_remote_pppoe -I br0 -k 
#pppoe-server -L 10.0.0.1 -p /etc/ppp/pool_remote_pppoe -I br0 -k 
#pppoe-server -L 10.0.0.1 -R 10.0.0.2 -N 64 -I br0 -k 
#pppoe-server -L 10.0.0.1 -R 10.0.0.2 -N 64 -I br0 -k -l
fi
