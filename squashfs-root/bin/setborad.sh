#!/bin/sh

BOARD_ID=1
eval `flash get HW_BOARD_ID`
if [ $HW_BOARD_ID != $BOARD_ID ]; then
	flash set HW_BOARD_ID $BOARD_ID
fi
