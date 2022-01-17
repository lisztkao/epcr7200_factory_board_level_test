#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[WIFI detection] - [WIFI]"
TEST_PARAMS="$1 $2"

 
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
INTERFACE=$1



	if [ -z "$INTERFACE" ]; then
	    INTERFACE=wlan0
	fi
	echo "INTERFACE:$INTERFACE"

	ifconfig $INTERFACE up
	
	sleep 1
	iw ${INTERFACE} disconnect
	if ! ifconfig $INTERFACE up; then
	    echo "Device $INTERFACE not found!"
	    RESULT=1
	else 
		echo "Device $INTERFACE up"
	fi
	sleep 4

	state=` ifconfig $INTERFACE | grep $INTERFACE | awk '/wlan/{x=$1} END{print x}'`
	if [ "$state" != "$INTERFACE" ]; then
	    echo "$INTERFACE state not up! please check wifi"
	    RESULT=1
	else 
	    echo "$INTERFACE state up!"
	    RESULT=0
	fi
	
 
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

