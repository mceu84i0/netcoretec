#!/bin/sh

if [ $# -lt 3 ]; then
	echo "----------------err: lost args,in host_route.sh-------------------------"
	exit 1
fi

if [ $1 = "add" ]; then
	route add -host $2 gw $3 
else
	route del -host $2 gw $3 
fi


