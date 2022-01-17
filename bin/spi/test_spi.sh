#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[spi test] - [spi]"
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
		spi-test -S -D "$INTERFACE" 0x11,0 | sed ':a;N;$!ba;s/\n/ /g' > tmp_spi
		spi_res=`cat tmp_spi`
		echo "address:0x11,0"
		echo "spi_res:$spi_res"
		if [ "$spi_res" == " 88 00  FF FF " ]; then
			echo "spi pass!"
		else
			echo "spi reg test fail"
			RESULT=1
		fi
		spi-test -S -D "$INTERFACE" 0x11,0xff | sed ':a;N;$!ba;s/\n/ /g' > tmp_spi
		spi_res=`cat tmp_spi`
		echo "address:0x11,0xff"
		echo "spi_res:$spi_res"
		if [ "$spi_res" == " 88 FF  FF FF " ]; then
			echo "spi pass!"
		else
			echo "spi reg test fail"
			RESULT=1
		fi

		
		
		spi-test -S -D "$INTERFACE" 0x09,0 | sed ':a;N;$!ba;s/\n/ /g' > tmp_spi
		spi_res=`cat tmp_spi`
		echo "address:0x09,0"
		echo "spi_res:$spi_res"
		if [ "$spi_res" == " 90 00  FF FF " ]; then
			echo "spi pass!"
		else
			echo "spi reg test fail"
			RESULT=1
		fi
		spi-test -S -D "$INTERFACE" 0x09,0xff | sed ':a;N;$!ba;s/\n/ /g' > tmp_spi
		spi_res=`cat tmp_spi`
		echo "address:0x09,0xff"
		echo "spi_res:$spi_res"
		if [ "$spi_res" == " 90 FF  FF FF " ]; then
			echo "spi pass!"
		else
			echo "spi reg test fail"
			RESULT=1
		fi

		
		
		spi-test -S -D "$INTERFACE" 0x01,0 | sed ':a;N;$!ba;s/\n/ /g' > tmp_spi
		spi_res=`cat tmp_spi`
		echo "address:0x01,0"
		echo "spi_res:$spi_res"
		if [ "$spi_res" == " 80 00  FF FF " ]; then
			echo "spi pass!"
		else
			echo "spi reg test fail"
			RESULT=1
		fi
		spi-test -S -D "$INTERFACE" 0x01,0xff | sed ':a;N;$!ba;s/\n/ /g' > tmp_spi
		spi_res=`cat tmp_spi`
		echo "address:0x01,0xff"
		echo "spi_res:$spi_res"
		if [ "$spi_res" == " 80 FF  FF FF " ]; then
			echo "spi pass!"
		else
			echo "spi reg test fail"
			RESULT=1
		fi
		
	fi
rm -f tmp_spi
 
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

