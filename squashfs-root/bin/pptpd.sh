#! /bin/sh

echo "********************************exec pptpd.sh********************"
eval `flash get PPTPD_ENABLE`

#killall pptpd
if [ $PPTPD_ENABLE -gt 0 ]; then
        flash gen-pptpd /etc/ppp/pptpd.conf /etc/ppp/options.pptpd /etc/ppp/chap-secrets

       if [ $# -gt 0 ] && [ $1 = "debug" ]; then
        	echo "debug" >> /etc/ppp/pptpd.conf
        fi

	pptpd_pppoe_deamon &
	#sleep 2
        /bin/pptpd -c /etc/ppp/pptpd.conf &
	#/bin/pptpd -c /etc/ppp/pptpd.conf -d &

        iptables -A INPUT -p gre -j ACCEPT
	iptables -A INPUT -p tcp --dport 1723 -j ACCEPT
	iptables -A INPUT -p udp --dport 1723 -j ACCEPT
fi
