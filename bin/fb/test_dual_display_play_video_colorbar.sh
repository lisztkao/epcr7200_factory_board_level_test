#!/bin/sh

echo 1 > /proc/sys/kernel/printk
if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
TEST_NAME="[DUAL DISPLAY] - [Playback video and show colorbar to HDMI, show colorbar to LVDS]"
TEST_PARAMS=$1
TEST_PROMPT_PRE="Look at the two monitors then press anykey..."
TEST_PROMPT_POST="Did you see the colorbar and video and hear the audio?"
function Test_Function
{
	#timeout 3s gst-launch-1.0 filesrc location=/home/root/advtest-factory/$HDMI_VIDEO_PATH ! decodebin name=dec dec. ! imxvideoconvert_g2d ! autovideosink dec. ! audioresample ! alsasink device="hw:'"$HDMI_AUDIO_DEV"'"
	timeout 3s gplay-1.0 /home/root/advtest-factory/$HDMI_VIDEO_PATH

	systemctl stop weston
	killall -9 weston
	sleep 3

	for N in $HDMI_COLORBAR_LIST; do
		timeout 3s modetest -s $N
        done

	for N in $LVDS_COLORBAR_LIST; do
                timeout 3s modetest -s $N
        done

	#killall gst-launch-1.0
	killall gplay-1.0
	weston-start
	systemctl start weston
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
echo 7 > /proc/sys/kernel/printk
