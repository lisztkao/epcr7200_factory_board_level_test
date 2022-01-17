#!/bin/sh

if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
SYSFS="/sys/class/gpio"
TEST_PARAMS=""
TEST_NAME="[GPIO] - [GPIO ports input\output]"


do_test () {
	echo -ne "loopback test for gpio$1 and gpio$2" "\t" "==> "
	echo in  > $SYSFS/gpio$1/direction
	echo out > $SYSFS/gpio$2/direction
	PASS=1
	for V in 0 1; do
		echo $V > $SYSFS/gpio$2/value
		RESULT=`cat $SYSFS/gpio$1/value`
		[ "$RESULT" != $V ] && PASS=0
	done
	[ $PASS == 1 ] && echo "PASS" || echo "FAIL"
	return $PASS
}


gpio_export() {
	for N in $GPIOLIST; do echo $N > $SYSFS/export 2>/dev/null; done		
}


gpio_unexport() {
	for N in $GPIOLIST; do echo $N > $SYSFS/unexport 2>/dev/null; done
}

function Test_Function
{
	S=1
	RETVAL=0
	COUNT=0
	for N in $GPIOLIST; do COUNT=$(($COUNT+1)); done
	gpio_unexport
	gpio_export
	while [ $S -lt $COUNT ]
	do
		do_test $S $(($S+1))
		if [ "$?" -eq "0" ];then
			gpio_unexport
			return 1
		fi
		S=$(($S+2))
	done
	gpio_unexport
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

