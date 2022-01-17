#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[CSI] - [Camera capture]"
TEST_PARAMS=""

do_test () {
	RESULT=0

        if [ ! -e "/dev/video$1" ]; then
                echo "/dev/video$1 not exist"
                return 1
        fi


	echo "===Taking a picture==="
	gst-launch-1.0 v4l2src device=/dev/video$1 num-buffers=1 ! 'video/x-raw,format=(string)YUY2,width=640,height=480,framerate=(fraction)30/1' ! jpegenc ! filesink location=/tmp/capture$1.jpeg &>/dev/null 
	sleep 1
	echo "===Show on monitor==="
	gst-launch-1.0 filesrc location=/tmp/capture$1.jpeg ! jpegdec ! imagefreeze ! autovideosink &>/dev/null &
	echo "Did you see the picture?(y/n)"
	read RESPONSE
	if [[ "$RESPONSE" == "y" ]]; then
		RESULT=0
	elif [[ "$RESPONSE" == "n" ]]; then
		RESULT=1
	fi
	killall gst-launch-1.0 &>/dev/null
	rm /tmp/capture$1.jpeg && sync
	return $RESULT
}

function Test_Function
{
	RETVAL=0
	echo "Camera will take a picture and show on monitor"
	
	for N in $CAMERALIST; do 
		sleep 2
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

