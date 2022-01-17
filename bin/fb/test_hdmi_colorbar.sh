#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[HDMI] - [Show colorbar and playback audio to HDMI]"
TEST_PARAMS=
TEST_PROMPT_PRE="Look at the HDMI Display then press anykey..."
TEST_PROMPT_POST="Did you see the colorbar and hear the audio?"
function Test_Function
{
	systemctl stop weston &>/dev/null
	SETTING=`./bin/fb/modelist.sh -s | grep $HDMI_RESOLUTION | grep "\-$HDMI_HZ"`
	if [ "$SETTING" == ""  ];then
		echo "===Not support 4K monitor==="
		return 1
	else
		echo "===SETTING is $SETTING==="
	fi
	sleep 2
	aplay -D plughw:"$HDMI_AUDIO_DEV",0 bin/fb/1.wav &
	modetest -s $SETTING 
	return 0
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
			Test_Function $TEST_PARAMS | tee -a $LOGFILE 2>&1
		else
			Test_Function $TEST_PARAMS
		fi
		RESULT=${PIPESTATUS[0]}
		if [ -n "$TEST_PROMPT_POST" ]; then
			if [ "$RESULT" == "0" ];then
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
            	fi
		systemctl start weston &>/dev/null
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
echo 7 > /proc/sys/kernel/printk
