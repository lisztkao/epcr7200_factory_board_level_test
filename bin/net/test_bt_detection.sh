#!/bin/bash 

argsnum=$#
echo 1 > /proc/sys/kernel/printk
if [[ ${!argsnum} == *.log ]]; then
	LOGFILE=${!argsnum}
fi
TEST_NAME="[BT] - [Test BT detection ]"


function Test_Function
{
	INTERFACE=$1
	#DRIVERTYPE=${parameters[1]}
	#NETWORK=${parameters[2]}
	#PASSWORD=${parameters[3]}
	
	if [ -z "$INTERFACE" ]; then
		INTERFACE=hci0
	fi

	if [ -z "$TIMEOUT" ]; then
		TIMEOUT=20
	fi
	

	# Disable RFKill
	if which rfkill > /dev/null; then
		rfkill unblock all
	fi
	
	if ! hciconfig $INTERFACE down; then    
            echo "Device $INTERFACE not found!"
            return 1                           
        fi                                     
        if ! hciconfig $INTERFACE up; then      
            echo "Device $INTERFACE not found!"
            return 1                                                  
        fi                                                              


	device=`hcitool dev | awk 'NR==2 {print $1}'`
	
	echo "$device"
	
	if [ $device == $INTERFACE ]; then
		echo "Bluetooth detection success!"
		hciconfig $INTERFACE down
		return 0	
	else
		echo "Bluetooth detection fail!"
		hciconfig $INTERFACE down
		return 0
	fi
	
	
	

}

if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi
unset INTERACTIVE
if [ -n "$TEST_PROMPT_PRE" ]; then
	INTERACTIVE=1
	echo "Interactive Test $TEST_NAME"
	unset RESULT

	while [ -z "$RESULT" ]; do
		echo "   $TEST_PROMPT_PRE"

		if [ -z "$TEST_PROMPT_POST" ]; then
			echo -n "   Press any key to continue"
			read
		else
			sleep 2
		fi

		#$TEST_COMMAND >> $LOGFILE 2>&1
		#RESULT=$?
		if [ -n "$LOGFILE" ]; then
			Test_Function $TEST_PARAMS >> $LOGFILE 2>&1
		else
			Test_Function $TEST_PARAMS
		fi
		RESULT=$?
		if [ -n "$TEST_PROMPT_POST" ]; then
			echo -n "   $TEST_PROMPT_POST (y/n/r[etry]): "
			read RESPONSE
			if [[ "$RESPONSE" == "y" ]]; then
				RESULT=0
			elif [[ "$RESPONSE" == "n" ]]; then
				RESULT=1
			else
				unset RESULT
			fi
		fi
	done

	printf "%-60s: " "$TEST_NAME"
else
	if [ -n "$LOGFILE" ]; then
		printf "%-60s: \n" "$TEST_NAME"
#		Test_Function $TEST_PARAMS >> $LOGFILE 2>&1
		set -o pipefail
		Test_Function $TEST_PARAMS 2>&1 | tee -a $LOGFILE
	else
		echo "Automated Test $TEST_NAME"
		echo ""
		Test_Function $TEST_PARAMS
	fi
	RESULT=$?
fi
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
sleep 2
echo 7 > /proc/sys/kernel/printk

