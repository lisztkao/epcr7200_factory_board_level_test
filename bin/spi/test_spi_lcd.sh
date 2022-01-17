#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[SPI_LCD test] - [SPI_LCD]"
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
		spi-test -S -D "$INTERFACE" 0x24,0x30 
		echo "Command 1	0x24,0x30 "
		spi-test -S -D "$INTERFACE" 0x24,0x30
		echo "Command 1	0x24,0x30 "
		spi-test -S -D "$INTERFACE" 0x24,0x30
		echo "Command 1	0x24,0x30 "
		spi-test -S -D "$INTERFACE" 0x24,0x30
		echo "Command 1	0x24,0x30 "
		spi-test -S -D "$INTERFACE" 0x24,0x08
		echo "Command 1	0x24,0x08 "
		spi-test -S -D "$INTERFACE" 0x24,0x01
		echo "Command 1	0x24,0x01 "
		spi-test -S -D "$INTERFACE" 0x24,0x07
		echo "Command 1	0x24,0x07 "
		spi-test -S -D "$INTERFACE" 0x24,0x30
		echo "Command 1	0x24,0x30 "
		spi-test -S -D "$INTERFACE" 0x24,0x0E
		echo "Command 1	0x24,0x0E "
		spi-test -S -D "$INTERFACE" 0x24,0x06
		echo "Command 1	0x24,0x06 "
		spi-test -S -D "$INTERFACE" 0x34,0x30
		echo "Command 1	0x24,0x30 "
		spi-test -S -D "$INTERFACE" 0x34,0x31
		echo "Command 1	0x34,0x31 "

		
		read -p "Please check lcd show 1(y/n): " show_res
		if [ "$show_res" == "y" ]; then
			echo "LCD test pass!"
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

