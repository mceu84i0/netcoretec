#! /bin/sh

if [ $1 = "connect" ]; then
	#add
	#delete it first
	iptables -D FORWARD -i $2 -s $3 -j ACCEPT
	iptables -D INPUT -i $2 -s $3 -j ACCEPT
	iptables -I FORWARD -i $2 -s $3 -j ACCEPT
	iptables -I INPUT -i $2 -s $3 -j ACCEPT
else
	#del
	iptables -D FORWARD -i $2 -s $3 -j ACCEPT
	iptables -D INPUT -i $2 -s $3 -j ACCEPT
fi

