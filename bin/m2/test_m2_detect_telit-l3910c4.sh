#!/bin/sh
echo 1 > /proc/sys/kernel/printk

RESULT=0
###=====================================================================
TELIT_LE910C4_PIDVID="1bc7:1201"
pidvid=`lsusb | grep $TELIT_LE910C4_PIDVID`
if [ -z "$pidvid" ]; then
	RESULT=1
else
	RESULT=0
fi
####======================================================================
 
if [ "$RESULT" == 0 ]; then
	echo "$pidvid"
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
		echo -en "FAILURE\n"
		echo ""
	else
		echo -en "FAILURE\n"
	fi
fi
sleep 1
echo 7 > /proc/sys/kernel/printk

