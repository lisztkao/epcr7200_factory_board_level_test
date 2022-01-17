#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[NOR Flash] - [NOR Flash Erase\Write]"
 
TEST_PROMPT_PRE=""
DEVICE_NAME=$1
BLKDEVICE_NAME=$2
Hostname=`cat /etc/hostname`
function Test_Function
{
	PART=0
	DEVICE=$1
	BLKDEVICE=$2
	echo "PART:$PART"
	echo "DEVICE:$DEVICE"
	echo "BLKDEVICE:$BLKDEVICE"


	echo "== Checking preloaded data in SPI ROM =="
	DUMP=`hexdump -e '8/1 "%02X" "\n"' -s 1024 -n 8 $DEVICE`
	echo $DUMP
	if [ "$DUMP" != "FFFFFFFFFFFFFFFF" ]; then
		echo $'== Exist preloaded data in SPI ROM! =='
		DUMP=`strings -n 30 $DEVICE |grep "U-Boot 2014"`
	        echo $DUMP
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

#	echo "== [START] Installing the boot-loader =="
#	UBOOTFILE="bin/mtd/u-boot-test.imx"
		
#	dd if=$UBOOTFILE of=$BLKDEVICE bs=512 seek=2
#	if [ $? -ne 0 ]; then
#		echo "Installing the boot-loader:    failed"
#		return 1
#	fi	
#	echo "== [END] Installing the boot-loader =="
			READ=`hexdump -n256 -C $DEVICE | head -n 1 | awk '{print $18 $19}' | cut -c 2-12`
			WRITE_DATA="HELLOWORLD!"
			echo "$WRITE_DATA" > $DEVICE
			READ=`hexdump -n256 -C $DEVICE | head -n 1 | awk '{print $18 $19}' | cut -c 2-12`

			if [[ $READ == $WRITE_DATA ]];then
				echo " Read/Write Pass "
				return 0
			else
				echo "Read/Write Failed "
				return 1
			fi

	return 0
}

if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi
unset INTERACTIVE
 
 
		printf "%-60s: \n" "$TEST_NAME"
		echo "test3"
		echo "DEVICE_NAME:$DEVICE_NAME"
		set -o pipefail                                         
                Test_Function $DEVICE_NAME $BLKDEVICE_NAME 2>&1 | tee -a $LOGFILE
 
	RESULT=$?
 
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

