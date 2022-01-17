#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[Audio] - [Audio input\output]"
TEST_PARAMS=""

TEST_PROMPT_PRE="Recording for 5 seconds, then play the recorded audio file"
TEST_PROMPT_POST="Did you hear the recorded audio?"



function Test_Function
{
	amixer set Mic 100% &> /dev/null 
	amixer set Headphone 100% &> /dev/null 
	echo "===Start recording==="
	arecord -t wav -c 1 -r 44100 -d 5 /tmp/mic.wav	&>/dev/null
	sleep 1
	echo "===Start playing==="
	aplay /tmp/mic.wav &>/dev/null
	rm /tmp/mic.wav
	sync
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

		echo  "   Press any key to start test"
		read

		if [ -n "$LOGFILE" ]; then
			Test_Function $TEST_PARAMS | tee -a $LOGFILE 2>&1
		else
			Test_Function $TEST_PARAMS
		fi
		#RESULT=$?
		if [ -n "$TEST_PROMPT_POST" ]; then
			echo  "   $TEST_PROMPT_POST (y/n/r[etry]): "
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

