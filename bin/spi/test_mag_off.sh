#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[mag test] - [mag]"
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
		echo "mag:$INTERFACE"
	fi
 
	if [ "$SKIPPINGTEST" != "1" ]; then
	    echo "can not find $INTERFACE "
	    RESULT=1
	else
		spi-test -S -D "$INTERFACE" 0x00,0 | sed ':a;N;$!ba;s/\n/ /g' > tmp_mag
		mag_res=`cat tmp_mag`
		echo "address:0x00"
		echo "mag_res:$mag_res"
		if [ "$mag_res" == " 00 00  FF FE " ]; then
			echo "mag  pass!"
		else
			echo "mag test fail"
			RESULT=1
		fi
		spi-test -S -D "$INTERFACE" 0x08,0xff | sed ':a;N;$!ba;s/\n/ /g' > tmp_mag
		mag_res=`cat tmp_mag`
		echo "address:0x08"
		echo "mag_res:$mag_res"
		if [ "$mag_res" == " 10 00  FF 3F " ]; then
			echo "mag  pass!"
		else
			echo "mag test fail"
			RESULT=1
		fi
	fi

rm -f tmp_mag
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

