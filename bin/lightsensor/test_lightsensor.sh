#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[Light Sensor] - [Light Sensor Read test]"
TEST_PARAMS=""
TEST_PROMPT_PRE="Test the lightsensor twice:"
TEST_PROMPT_POST1="Cover the lightsensor then press any key"
TEST_PROMPT_POST2="Dose lightsensor change?"

function Test_Function
{
	
	
	if [[ ! -d "/sys/devices/soc0/soc/2100000.aips-bus/21a8000.i2c/i2c-2/2-0029/iio:device0" ]]; then
		echo "Light Sensor detection failed!"
		return 1
	else
		light_value=`cat /sys/devices/soc0/soc/2100000.aips-bus/21a8000.i2c/i2c-2/2-0029/iio:device0/in_illuminance0_input`
		if [ $? -eq 0 ]; then
			echo "Light Sensor: $light_value"
			return 0
		else
			echo "Light Sensor get value failed! "
			return 1
		fi
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

		#if [ -z "$TEST_PROMPT_POST" ]; then
			#echo -n "   Press any key to continue"
			#read
        #    	else
         #       	sleep 2
         #   	fi

		#$TEST_COMMAND >> $LOGFILE 2>&1
		#RESULT=$?
		if [ -n "$LOGFILE" ]; then
			#Test_Function $TEST_PARAMS >> $LOGFILE 2>&1
			Test_Function $TEST_PARAMS
		else
			Test_Function $TEST_PARAMS
		fi

		if [ -n "$TEST_PROMPT_POST1" ]; then
			echo -n "   $TEST_PROMPT_POST1: "
			read

			if [ -n "$LOGFILE" ]; then
				#Test_Function $TEST_PARAMS >> $LOGFILE 2>&1
				Test_Function $TEST_PARAMS
			else
				Test_Function $TEST_PARAMS
			fi

		fi

		RESULT=$?
		if [ -n "$TEST_PROMPT_POST2" ]; then
			echo -n "   $TEST_PROMPT_POST2 (y/n/r[etry]): "
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

