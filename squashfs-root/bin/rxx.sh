#!/bin/sh
eval `/bin/flash get ADVANCE_SERVER_IP_ADDR`
eval `/bin/flash get ADVANCE_SERVER_IP_PORT`
rxxV4 $ADVANCE_SERVER_IP_ADDR /dev/ttyS0 $ADVANCE_SERVER_IP_PORT
