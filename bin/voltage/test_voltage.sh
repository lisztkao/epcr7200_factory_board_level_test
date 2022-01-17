#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi

 
LOGFILE_VOL=${LOGFILE}"-"${INTERFACE_NAME:105}
 
if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE_VOL
	echo "" >> $LOGFILE_VOL
	echo "$(date)" >> $LOGFILE_VOL
	echo "============================" >> $LOGFILE_VOL
fi
unset INTERACTIVE
 
	INTERACTIVE=1
	echo "Interactive Test $TEST_NAME"
	unset RESULT
RESULT=0
###=====================================================================
INTERFACE_NAME=$1
VOLTAGE_LOW=$2
VOLTAGE_HI=$3
	
	
	if [ -z "$INTERFACE_NAME" ]; then
	    SKIPPINGTEST=0
	fi

	if [ "$SKIPPINGTEST" == "0" ]; then
	    echo "can not find $INTERFACE_NAME "
	    RESULT=1
	else

		cat $INTERFACE_NAME > tmp_voltage
		voltage_res=`cat tmp_voltage`
		echo "VOLTAGE_HI:$VOLTAGE_HI, VOLTAGE_LOW:$VOLTAGE_LOW, voltage_res:$voltage_res"

		if [  $voltage_res -gt $VOLTAGE_LOW ]; then
			
			if [  $voltage_res -lt $VOLTAGE_HI ]; then
			echo "voltage  pass!"
			
			else
			echo "voltage out of range fail"
			RESULT=1
			fi
		else
			echo "voltage out of range fail"
			RESULT=1
		fi
	fi

rm -f tmp_voltage

####======================================================================
		
 

 
if [ "$RESULT" == 0 ]; then
	if [ -n "$LOGFILE_VOL" ]; then
		echo "============================" >>  $LOGFILE_VOL
        	echo "SUCCESS" >> $LOGFILE_VOL
	fi
	if [ -n "$INTERACTIVE" ]; then
		echo -en "SUCCESS\n"
		echo ""
	else
		echo -en "SUCCESS\n"
        fi
else
	if [ -n "$LOGFILE_VOL" ]; then
		echo "============================" >> $LOGFILE_VOL
        	echo "FAILURE" >> $LOGFILE_VOL
	fi
	if [ -n "$INTERACTIVE" ]; then
		echo -en "FAILURE\n"                    
		echo ""
	else
		echo -en "FAILURE\n"
	fi
fi
sleep 1


echo""

echo 7 > /proc/sys/kernel/printk

