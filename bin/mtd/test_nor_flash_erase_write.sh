#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[NOR Flash] - [NOR Flash Erase\Write]"
TEST_PARAMS=""
TEST_PROMPT_PRE=""

Hostname=`cat /etc/hostname`
function Test_Function
{
	PART=0
	DEVICE=/dev/mtd$PART
	BLKDEVICE=/dev/mtdblock$PART
	

	echo "== Checking preloaded data in SPI ROM =="
	DUMP=`hexdump -e '8/1 "%02X" "\n"' -s 1024 -n 8 $DEVICE`
	echo $DUMP
	if [ "$DUMP" != "FFFFFFFFFFFFFFFF" ]; then
		echo $'== Exist preloaded data in SPI ROM! =='
		DUMP=`strings -n 30 $DEVICE |grep "U-Boot 2014"`
	        echo $DUMP
	        #if [[ $DUMP != *"U-Boot 2014.07-g5d5a8c8-dirty"* ]]; then
        	#        printf "%s\n" "== Exist preloaded data in SPI ROM! =="
	        #        printf "%s\n" "Erasing the SPI ROM: SKIP"
        	#        return 0
	        #else
        	#        echo "OK"
			#fi
	else
		echo "OK"
	fi

	if [ ! -f $UBOOTFILE ]; then
		echo "Please put u-boot.imx to the current directory"
		return 1
	fi
	
	echo "== [START] Erasing the SPI ROM =="
	flash_eraseall $DEVICE
	if [ $? -ne 0 ]; then
		echo "Erasing the SPI ROM:    failed"
		return 1
	fi	
	echo "== [END] Erasing the SPI ROM =="

	echo "== [START] Installing the boot-loader =="
	if [[ "$Hostname" == *"imsse01"* ]]; then
			UBOOTFILE="bin/mtd/u-boot-imx6q-imsse01.imx"
    elif [[ "$Hostname" == *"dmsse23"* ]]; then
			UBOOTFILE="bin/mtd/u-boot-imx6dl-dmsse23.imx"
		else
			echo "check device name fail"
			return 1
		fi
		
	dd if=$UBOOTFILE of=$BLKDEVICE bs=512 seek=2
	if [ $? -ne 0 ]; then
		echo "Installing the boot-loader:    failed"
		return 1
	fi	
	echo "== [END] Installing the boot-loader =="
	
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
			#set -o pipefail                                         
                        #Test_Function $TEST_PARAMS 2>&1 | tee -a $LOGFILE
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
		printf "%-60s: \n" "$TEST_NAME"
		#Test_Function $TEST_PARAMS >> $LOGFILE 2>&1
		set -o pipefail                                         
                Test_Function $TEST_PARAMS 2>&1 | tee -a $LOGFILE
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

