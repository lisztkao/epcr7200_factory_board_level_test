#!/bin/sh
echo 1 > /proc/sys/kernel/printk

RESULT=0
###=====================================================================
AW_CB375NF_M2_USB_PIDVID="13d3:3549"
AW_CB375NF_M2_PCIE_ID="c822"
pidvid=`lsusb | grep $AW_CB375NF_M2_USB_PIDVID`
pcieid=`lspci | grep $AW_CB375NF_M2_PCIE_ID`
if [ -z "$pidvid" -a -z "$pcieid" ]; then
	RESULT=1
else
	RESULT=0
fi
####======================================================================
 
if [ "$RESULT" == 0 ]; then
	echo "$pidvid"
	echo "$pcieid"
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

