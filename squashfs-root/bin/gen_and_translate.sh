#! /bin/sh

if [ $# -ne 3 ]; then
	echo "$0 need three args:"
	echo "usage: <path> <ip of remote> <name of remote>"
	exit 1
fi

path=$1
remote_ip=$2
rnam=$3
dev1=/dev/mtdc1
dev2=/dev/mtdc2

rm $path

get_image.sh $dev1 $path
if [ $? -ne 0 ]; then
	echo "ERROR: get content of $dev1 failed!!!"
	exit 2
fi
echo "$dev1 have ok"

get_image.sh $dev2 $path
if [ $? -ne 0 ]; then
	echo "ERROR: get content of $dev2 failed!!!"
	exit 3
fi
echo "$dev2 have ok"

echo "Now tftp to $remote_ip, save as $rnam"
tftp -l $path -p -r $rnam $remote_ip
if [ $? -ne 0 ]; then
	echo "ERROR: get content of $dev2 failed!!!"
	exit 4
else
	echo "Ok, have save $path to $remote_ip, as name: $rnam"
fi
