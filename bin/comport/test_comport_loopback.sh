#!/bin/sh

if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
TEST_NAME="[COM] - [COMPORT LOOPBACK $1]"
TEST_PARAMS=$1

fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"

RETVAL=0

function Test_Function
{
	RETVAL=0
    UART_PORT=$1
	
	
	if [ -f $UART_PORT.txt ]; then
	   rm $UART_PORT.txt
	fi

	stty -F /dev/$UART_PORT 115200 cs7 -parodd -parenb -cstopb -icanon -iexten -ixon -ixoff -crtscts -cread -clocal -echo -echoe -echok -echoctl

	cat /dev/$UART_PORT > $UART_PORT.txt & >/dev/null
	cat_pid=$!
	sync
	
	echo "1234567890abcdefghijklmnopqrstuvwxyz!" >/dev/$UART_PORT
	sleep 1 && sync

	get_data=`grep -r 1234567890abcdefghijklmnopqrstuvwxyz! $UART_PORT.txt`
	
	kill $cat_pid &>/dev/null
	ps &>/dev/null
	if [[ "$get_data" == *"1234567890abcdefghijklmnopqrstuvwxyz!"* ]];then
		RETVAL=0
	else
		RETVAL=1
	fi		

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

