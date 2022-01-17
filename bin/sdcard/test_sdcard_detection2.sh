#!/bin/sh

if [[ $2 == *.log ]]; then
	LOGFILE=$2
fi
TEST_NAME="[SDcard] - [SDcard detection]"
TEST_PARAMS="$1"

fifoStr="01234567890abcdefghijklmnopqrstuvwxyz!@#$%^&*()"
declare -A mmc_type_group
for i in `ls /sys/bus/mmc/devices/`
do
        mmc_type_group[$i]=`cat /sys/bus/mmc/devices/$i/type`

done
return_emmc_dev() {

        for i in "${!mmc_type_group[@]}"
        do
                if [[ "${mmc_type_group[$i]}" == "SD" ]];then
                        echo | ls /sys/bus/mmc/devices/$i/block/
                fi
        done
}


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
		 
		sdcardev=`return_emmc_dev`
		echo "sdcardev=$sdcardev"
		
		partition_sd=`fdisk -l | grep "$sdcardev"p2`
		
		
		if [[ $partition_sd == "" ]]; then
				new_partition="$sdcardev"p1
				echo "not find sd partition"
				dd if=/dev/zero of=/dev/$sdcardev  bs=512  count=1
fdisk /dev/$sdcardev &>/dev/null << EOF
n
p
1

+1024M
n
p
2


w
q
EOF

				sync && sync && sleep 1
				mkfs.ext4 /dev/$new_partition &>/dev/null
				sync && sync && sleep 1
				if [[  -e "/dev/$new_partition" ]]; then
					RESULT=0
					TMPDIR=`mktemp -d`
					if `mount "/dev/$1" $TMPDIR &>/dev/null` ;then
						echo $fifoStr > "$TMPDIR/test.txt"
						ReadStr=`cat $TMPDIR/test.txt`
						if [ $fifoStr == $ReadStr ]; then
							echo "write/read pass"
							RESULT=0
						else
							echo "write/read fail"
							RESULT=1
						fi
						sleep 1
						rm $TMPDIR/test.txt
					else
						echo "write/read pass"
						RESULT=0
					fi
				else
					RESULT=1
					echo "write/read fail"
				fi
				fdisk -l /dev/$sdcardev   >> $LOGFILE 2>&1
		
		else
			echo "sd partition exist"
			TMPDIR=`mktemp -d`
			if `mount "/dev/$1" $TMPDIR &>/dev/null` ;then
				echo $fifoStr > "$TMPDIR/test.txt"
				ReadStr=`cat $TMPDIR/test.txt`
				if [ $fifoStr == $ReadStr ]; then
					echo "write/read pass"
					RESULT=0
				else
					echo "write/read fail"
					RESULT=1
				fi
				sleep 1
				rm $TMPDIR/test.txt
			else
				echo "write/read pass"
				RESULT=0
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

