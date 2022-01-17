#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $3 == *.log ]]; then
	LOGFILE=$3
fi
TEST_NAME="[keypad test] - [keypad]"
TEST_PARAMS="$1 $2"

 
if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi
unset INTERACTIVE
echo ""
echo ""
echo ""
echo ""
echo ""
	INTERACTIVE=1
	echo "Interactive Test $TEST_NAME"
	unset RESULT
RESULT=0
###=====================================================================
interrupt_name=$1
key_name=$2
	
	
	if [ -z "$interrupt_name" ]; then
	    SKIPPINGTEST=0
	fi


 
 
	if [ "$SKIPPINGTEST" == "0" ]; then
	    echo "can not find $interrupt_name "
	    RESULT=1
	else
		cat /proc/interrupts | grep $interrupt_name | awk '/magmon/{x=$2} END{print x}' > tmp_interrupt
		interrupt_res=`cat tmp_interrupt`
###		echo "interrupt_res:$interrupt_res"
		pause "Press $key_name keypad!!!      Then press any key to continue..."
		
		cat /proc/interrupts | grep $interrupt_name | awk '/magmon/{x=$2} END{print x}' > tmp_interrupt2
		interrupt_res2=`cat tmp_interrupt2`
###		echo "interrupt_res2:$interrupt_res2"
		
		if [ "$interrupt_res" == "$interrupt_res2" ]; then
			echo "interrupt  fail!"
			RESULT=1
		else
			echo "interrupt test pass"
		fi
	fi

rm -f tmp_interrupt2
rm -f tmp_interrupt

####======================================================================
		

LOGFILE_KEY=${LOGFILE}"-"${key_name}
 
if [ "$RESULT" == 0 ]; then
	if [ -n "$LOGFILE_KEY" ]; then
		echo "============================" >>  $LOGFILE_KEY
        	echo "SUCCESS" >> $LOGFILE_KEY
	fi
	if [ -n "$INTERACTIVE" ]; then
		echo -en "SUCCESS\n"
		echo ""
	else
		echo -en "SUCCESS\n"
        fi
else
	if [ -n "$LOGFILE_KEY" ]; then
		echo "============================" >> $LOGFILE_KEY
        	echo "FAILURE" >> $LOGFILE_KEY
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

