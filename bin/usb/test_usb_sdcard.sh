#!/bin/sh

if [[ $1 == *.log ]]; then
	LOGFILE=$1
fi
TEST_NAME="[USB_SD] - [USB_SD read and write]"
TEST_PARAMS="$1"

fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"
  

if [ -n "$LOGFILE" ]; then
	echo "$TEST_NAME" > $LOGFILE
	echo "" >> $LOGFILE
	echo "$(date)" >> $LOGFILE
	echo "============================" >> $LOGFILE
fi


unset INTERACTIVE
TEST_PROMPT_PRE=1
INTERACTIVE=1
unset RESULT
RESULT=1

	if [ -n "$LOGFILE" ]; then
		ls /dev | grep sda1 > sda_temp
		dev_sda=`cat sda_temp`
		echo "dev_sda:$dev_sda"
		if [  -z "$dev_sda" ] ;then
			echo "not find sd partition"
			RESULT=1 
		else
			echo "sd partition exist"
			mkdir "/mnt/usb_sd"
			mount -v -t auto /dev/sda1 /mnt/usb_sd 
			mount_sda=`cat /proc/mounts | grep /dev/sda1`
			if [  -z "$mount_sda" ] ;then
				echo "mount fail"
				RESULT=1
			else
				echo "mount usb sd"
				echo $fifoStr > "/mnt/usb_sd/test.txt"
				sync 
				sleep 1
				ReadStr=`cat /mnt/usb_sd/test.txt`
				if [ $fifoStr == $ReadStr ]; then
					echo "write/read pass"
					RESULT=0
				else
					echo "write/read fail"
					RESULT=1
				fi

				rm "/mnt/usb_sd/test.txt"
				sync
				umount "/mnt/usb_sd"
				sleep 1
				sync
				rm -rf "/mnt/usb_sd/"
				rm -f "sda_temp"
			
			fi
			fdisk -l /dev/$sdcardev   >> $LOGFILE 2>&1
		fi
		
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

