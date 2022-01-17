#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[CAN1 loop CAN2] - [CAN1 loop CAN2 test]"


 
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

echo "reset can bus"
./bin/can_bus/reset.sh
echo "can bus loopback test "
./bin/can_bus/cantest/cantest > res_can
RES_TEMP=`cat res_can`
echo "$RES_TEMP"
RES_CAN=`cat res_can | grep OK`
	if [ -z "$RES_CAN"  ]; then
		echo "CAN1 loop CAN2 test fail"
		echo "CAN1 loop CAN2 test fail" >> $LOGFILE
		RESULT=1
	else
		echo "CAN1 loop CAN2 test pass!"
		echo "CAN1 loop CAN2 test pass!" >> $LOGFILE
		RESULT=0
	fi
 
rm -f res_can
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

