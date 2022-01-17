#!/bin/sh

if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
TEST_PARAMS=""
TEST_NAME="[UART] - [RS-485 PORT to PORT test]"
SINGLE_RS485_TEST_STRING="123456789abcde"
SINGLE_RS485_TEST_RESULT=""

do_single_rs485_test () {
	stty -F $SINGLE_RS485_PORT speed 115200 -hupcl -icrnl -ixon -opost -onlcr -isig -icanon -iexten -echo -echoe -echok -echoctl -echok
	cat $SINGLE_RS485_PORT > /tmp/rs485_data &
	echo "Test $SINGLE_RS485_PORT send to other device"
	echo $SINGLE_RS485_TEST_STRING > $SINGLE_RS485_PORT
	sleep 5
	killall cat
	SINGLE_RS485_TEST_RESULT=$(cat /tmp/rs485_data)
	echo $SINGLE_RS485_TEST_RESULT
	killall cat
	rm /tmp/rs485_data
	if [ "$SINGLE_RS485_TEST_RESULT" == "$SINGLE_RS485_TEST_STRING" ]; then
		echo "PASS"
		return 1
	else
		echo "FAIL"
		return 0
	fi
}

do_test () {
	echo -ne "RS-485 test for "$UART_DEV""$1" and "$UART_DEV""$2"" "\t" "==> "

	cat /dev/"$UART_DEV""$1" > /tmp/"$UART_DEV""$1"out &
        usleep 200000
        echo "hello12345" > /dev/"$UART_DEV""$2"
        usleep 200000
	killall cat
	cat /dev/"$UART_DEV""$2" > /tmp/"$UART_DEV""$2"out &
	usleep 200000
	echo "hello12345" > /dev/"$UART_DEV""$1"
	usleep 200000
	killall cat
	if [ "`cat /tmp/"$UART_DEV""$1"out`" == "" ];then 
		echo "FAIL"
		return 0
	fi	
        if [ "`cat /tmp/"$UART_DEV""$1"out`" == "`cat /tmp/"$UART_DEV""$2"out`" ];then
                echo "PASS"
                return 1
        else
                echo "FAIL"
                return 0
        fi
	
	return $PASS
}

enable_rs485() {
	for N in $UART_RS485_LIST; do 
		echo "Enable "$UART_DEV""$N" rs-485 function"
		./bin/uart/"$ENABLE_RS485" /dev/"$UART_DEV""$N" 
		stty -F /dev/"$UART_DEV""$N" speed 115200 -echo; &>/dev/null
	done		
}

function Test_Function
{
	S=1
	RETVAL=0
	COUNT=0

	if [[ -n "$SINGLE_RS485_PORT" ]]; then
		echo "do single rs485 test"
		do_single_rs485_test
		if [ "$?" -eq "0" ];then
			return 1
		else
			return 0
		fi
	fi

	for N in $UART_RS485_LIST; do 
		COUNT=$(($COUNT+1))
		ARRAY+=("$N")
	done
	enable_rs485
	while [ $S -lt $COUNT ]
	do
		do_test ${ARRAY[$S-1]} ${ARRAY[($S)]}
		if [ "$?" -eq "0" ];then
			return 1
		fi
		S=$(($S+2))
	done
	rm /tmp/"$UART_DEV"* && sync
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

