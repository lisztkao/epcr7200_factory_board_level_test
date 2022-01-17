#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[Audio] - [Audio input\output]"
TEST_PARAMS=""

if [[ -d "/sys/firmware/devicetree/base/soc/aips-bus@02000000/iomuxc@020e0000/imx6q-imsse01" ]]; then
	TEST_PROMPT_PRE="Playing the audio file for 5 seconds"
else 
	TEST_PROMPT_PRE="Recording for 5 seconds, then play the recorded audio file"
fi	
	TEST_PROMPT_POST="Did you hear the recorded audio?"



function Test_Function
{
	
	amixer cset numid=2,iface=MIXER,name='Capture Volume' 15 &>/dev/null
	amixer cset numid=5,iface=MIXER,name='Headphone Playback Volume' 127 &>/dev/null
	
	if [[ -d "/sys/firmware/devicetree/base/soc/aips-bus@02000000/iomuxc@020e0000/imx6q-imsse01" ]]; then
		aplay bin/audio/music.wav
	else 
		arecord -d 5 -f cd -t wav /tmp/test-mic.wav
		sleep 1
		aplay /tmp/test-mic.wav
		sleep 1
		rm /tmp/test-mic.wav
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
			echo -n "   Press any key to continue"
			read
            	#else
                #	sleep 2
            	#fi

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

