#!/bin/sh

UPSTREAM_IF="$1"
DOWNSTREAM_IF="$2"
DISABLED_IF="$3"

eval `flash get IGMP_PROXY_DISABLED`
if [ "$IGMP_PROXY_DISABLED" = "0" ];then
	igmp $UPSTREAM_IF &
fi
