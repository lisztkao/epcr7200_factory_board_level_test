#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[GPIO] - [Power input detection]"
TEST_PARAMS=""

in_gpioPort="110"
in_name_gpioport="Q7_3V3_PWGIN_IN"

gpio_unexport() {
	echo "$1" > /sys/class/gpio/unexport 
}

gpio_export() {
	if [ -d /sys/class/gpio/gpio$1 ] ; then
		gpio_unexport $1
	fi
	echo $1 > "/sys/class/gpio/export"
}

gpio_dir_out() {
	echo "out" > "/sys/class/gpio/gpio$1/direction"
}

gpio_dir_in() {
	echo "in" > "/sys/class/gpio/gpio$1/direction"
}

gpio_read() {
	cat /sys/class/gpio/gpio$1/value
}	

gpio_write() {
	echo "$2" > /sys/class/gpio/gpio$1/value
}	
function Test_Function
{
	RETVAL=0
	gpio_export $in_gpioPort
	gpio_dir_in $in_gpioPort
	gpio_v='1'
	gpio_in=`cat /sys/class/gpio/gpio$in_gpioPort/value`

	if [[ $gpio_in != $gpio_v ]];then
		echo "$in_name_gpioport    (value:$gpio_in)    failed"	
		RETVAL=1
	else
		echo "$in_name_gpioport    (value:$gpio_in)    pass"
	fi
	gpio_unexport $in_gpioPort
	
	return $RETVAL	
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

