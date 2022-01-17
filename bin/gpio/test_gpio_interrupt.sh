#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[GPIO] - [GPIO key interrupt]"
TEST_PARAMS=""

do_test () {
	i=5
	RESULT=0

	INTER_PRE=`cat /proc/interrupts | grep $1 | awk '{print $2}'`
	echo ""
	echo "===Press "$1" key then release key in 5 secs="
	while [ "${i}" -gt 0 ];
	do
		echo $i
		i=$(($i-1))    
		sleep 1
	done
	INTER_POST=`cat /proc/interrupts | grep $1 | awk '{print $2}'`
	if [ $INTER_PRE == $INTER_POST ];then
		RESULT=1
	fi
	echo "Test OK"
	return $RESULT
}

function Test_Function
{
	RETVAL=0
	killall key_event	
	for N in $KEY_LABEL_LIST; do 
		do_test	$N
		if [ "$?" -eq "1" ];then
			return 1
		fi
	done
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
		Test_Function $TEST_PARAMS $@ | tee -a $LOGFILE 2>&1
	else
		echo "Automated Test $TEST_NAME"
		echo ""
		Test_Function $TEST_PARAMS
	fi
	RESULT=${PIPESTATUS[0]}
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

