#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[CONFIG] - [Battery SN check]"

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
BATT_SYSFS="/sys/class/power_supply/battery/serial_number"

# BATT_SN - input
BATT_SN_CHK=$1

# BATT_SN - device
BATT_SN_VPM=$(cat $BATT_SYSFS)

if [ -z "$BATT_SN_CHK"  ]; then
	echo "Battery SN input is null" | tee -a $LOGFILE
	RESULT=1
else
	echo "[BATT_SN_CHK] : $BATT_SN_CHK" | tee -a $LOGFILE
	echo "[BATT_SN_VPM] : $BATT_SN_VPM" | tee -a $LOGFILE
	
	if [ "$BATT_SN_VPM" == "$BATT_SN_CHK" ]; then
		RESULT=0
	else
		RESULT=1
	fi
fi

####======================================================================

if [ "$RESULT" == 0 ]; then
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

