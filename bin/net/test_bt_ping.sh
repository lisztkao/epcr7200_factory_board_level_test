#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[BT ping] - [BT]"

INTERFACE=$1
BT_MAC=$2
BT_COUNTER=$3

LOGFILE_NEW=${LOGFILE}"-"${BT_MAC}
LOGFILE=${LOGFILE_NEW}

if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi
unset INTERACTIVE
 
	INTERACTIVE=1
	echo "Interactive Test $TEST_NAME"
	unset RESULT
RESULT=0
###=====================================================================

	if [ -z "$INTERFACE" ]; then
		INTERFACE="hci0"
	fi

	read -p "Please input ap name. (enter to default:$INTERFACE): " NEW_INTERFACE
	if [ -z "$NEW_INTERFACE" ]; then
		INTERFACE=$INTERFACE
	else
		INTERFACE=$NEW_INTERFACE
	fi

	echo "INTERFACE:$INTERFACE"
	hciconfig $INTERFACE down
	sleep 1
	hciconfig $INTERFACE up
	sleep 2

	for((i=0;i<6;i++)) do
		hciconfig $INTERFACE | grep "UP" > temp_status
		status_res=`cat temp_status`
		if [ -z "$status_res" ]; then
			echo "."
		else
			break
		fi
		if [ "$i" == "5" ]; then
			RESULT=1
			echo "can't set up"
		fi
		sleep 1
	done
	rm -f temp_status

	if [  -z "$BT_MAC"  ]; then
		BT_MAC="F8:94:C2:8F:F8:C1"
	fi

	if [ "$RESULT" == "0" ]; then
		read -p "Please input ap name. (enter to default:$BT_MAC): " NEW_BT
		if [ -z "$NEW_BT" ]; then
			echo "BT_MAC $BT_MAC"
		else
			BT_MAC=$NEW_BT
			echo "BT_MAC $BT_MAC"
		fi
	fi

###==========================================================================
	l2ping  $BT_MAC  -c $BT_COUNTER | grep %   > temp_ping
	ping_res=`cat temp_ping `
	echo "$ping_res"
	ping_res=`cat temp_ping | awk '/loss/{x=$5} END{print x}'`
	if [ "$ping_res" == "0%" ]; then
		echo "ping pass!"
		echo "ping pass!" >> $LOGFILE
	else
		echo "ping timeout loss:$ping_res"
		echo "ping timeout loss:$ping_res" >> $LOGFILE
		RESULT=1
	fi
	rm -f temp_ping

####======================================================================

if [ "$RESULT" == "0" ]; then
	if [ -n "$LOGFILE" ]; then
		echo "============================" >> $LOGFILE
		echo "SUCCESS" >> $LOGFILE
	fi
	if [ -n "$INTERACTIVE" ]; then
		echo -en "SUCCESS\n"
		echo ""
	else
		echo -en "SUCCESS\n"
	fi
else
	if [ -n "$LOGFILE" ]; then
		echo "============================" >> $LOGFILE
		echo "FAILURE" >> $LOGFILE
	fi
	if [ -n "$INTERACTIVE" ]; then
		echo   "FAILURE"
	else
		echo   "FAILURE"
	fi
fi

echo 7 > /proc/sys/kernel/printk

