#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[Battery] - [Battery charging detection test]"
TEST_PARAMS=""
TEST_PROMPT_PRE="Please plug the AC power"


check_battery_status() {
	COUNT=0
	CHARGING=`cat $BATTERY_STATUS | grep $1` 
	while [ -z $CHARGING ]; do
		CHARGING=`cat $BATTERY_STATUS | grep $1` 
		COUNT=$(($COUNT+1))
		if [ $COUNT -gt 5 ];then
			return 1
			break;
		fi
	done
	return 0
}

function Test_Function
{
	check_battery_status "Charging"
	if [ "$?" -eq "0" ]; then
		echo "***Battery Charging detection OK!***"
		echo ""
		echo "   Please unplug the AC power"
		echo -n "   Press any key to continue"
		read
		sleep 3
		check_battery_status "Discharging"
			
		if [ "$?" -eq "0" ]; then
			echo "***Battery Discharging detection OK!***"
			return 0
		else
			return 1
		fi
		
	else
		echo "Battery Charging detection failed!"
		return 1	
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
		if [ ! -f "$BATTERY_STATUS" ]; then
			echo "   Please plug the Battery"
			echo -n "   Press any key to continue"
			read
			rmmod bq40z50_fg &> /dev/null
			modprobe bq40z50_fg &> /dev/null
		fi
		echo "   $TEST_PROMPT_PRE"

		if [ -z "$TEST_PROMPT_POST" ]; then
			echo -n "   Press any key to continue"
			read
                	sleep 3
            	else
                	sleep 2
            	fi

		#$TEST_COMMAND >> $LOGFILE 2>&1
		#RESULT=$?
		if [ -n "$LOGFILE" ]; then
			Test_Function $TEST_PARAMS 
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
		printf "%-60s: " "$TEST_NAME"
		Test_Function $TEST_PARAMS >> $LOGFILE 2>&1
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

