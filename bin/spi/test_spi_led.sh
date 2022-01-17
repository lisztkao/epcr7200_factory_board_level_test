#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[SPI_LED test] - [SPI_LED]"
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
	    INTERFACE=0
	fi


	if [ -e "$INTERFACE" ]; then
	    SKIPPINGTEST=1
	else 
		echo "spi:$INTERFACE"
	fi
 
	if [ "$SKIPPINGTEST" != "1" ]; then
	    echo "can not find $INTERFACE "
	    RESULT=1
	else
		spi-test -S -D "$INTERFACE" 0x11,0x20
		echo "Command 	0x11,0x20 "
		
		read -p "Please check alarm led turn on(y/n): " show_alarm_res
		
		spi-test -S -D "$INTERFACE" 0x11,0x80
		echo "Command 	0x11,0x80 "
		
		read -p "Please check heater led turn on(y/n): " show_heater_res
		if [ "$show_alarm_res" == "y" ]; then
			if [ "$show_heater_res" == "y" ]; then
				echo "LCD test pass!"
				RESULT=0
			else
				echo "LCD test fail"
				RESULT=1
			fi
		else
			echo "LCD test fail"
			RESULT=1
		fi
	fi
 
 
####		ifconfig $INTERFACE down
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

