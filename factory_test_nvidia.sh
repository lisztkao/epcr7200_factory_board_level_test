#!/bin/bash 

#/home/root/advtest/factory
if [ -d ".git" ]; then
Ver=`git log -1 --format="%at" | xargs -I{} date -d @{} +%Y/%m/%d_%H:%M:%S`
else
Ver="No data"
fi
LANG=C
LANGUAGE="en_US.UTF-8"

export Hostname=`cat /etc/hostname`

echo 4 4 4 4 > /proc/sys/kernel/printk

if [ $USER != "root" ]
then
	echo "is not root ?"
	exit
fi
#NTPSERVER='192.123.53.2'
#WEBSERVER='192.123.53.2'
#NTPSERVER='192.168.11.186'
#WEBSERVER='192.168.11.186'
WEBSERVER='www.baidu.com'
NTPSERVER='time.stdtime.gov.tw'
HOST0_boardR_IP=172.168.0.1 #BoardR master IP
eth0_boardR_IP=172.168.0.2 #BoardR slave IP

DATE=$(date "+%Y%m%d%H%M%S")

LOGDIR=""
Normal='\e[0m'
BGreen='\e[1;32m'
BRed='\e[1;31m'

function run_test
{
	LOGDIR=./logs/temp/`date "+%Y%m%d%H%M%S"`/
	mkdir -p $LOGDIR
	echo ""
	echo "Test Log Directory : ${LOGDIR}"
	echo "==============================="
	TEST_NAME=$1
	TEST_PATH=$2
	TEST_PARAMS=$3
	TEST_PROMPT_PRE=$4
	TEST_PROMPT_POST=$5
	TEST_COMMAND="$TEST_PATH $TEST_PARAMS"
	TEST_NAME_SAFE=$(echo $TEST_NAME | sed -e 's/ /_/g')
	LOGFILE=$LOGDIR/$TEST_NAME_SAFE.log
	source $TEST_COMMAND $LOGFILE
}

system_init() {
	if ! command -v udhcpc &> /dev/null
	then
		apt install -y udhcpc
	fi
	clear
	stty erase '^H'
	stty erase '^?'	
}

end_test() {
	echo "Finish."
}

pause() {
	read -n 1 -p "$*" INP
	if [[ $INP != '' ]] ; then
		echo -ne '\b \n'
	fi
}
 
do_test() {
	echo 1 > /proc/sys/kernel/printk
	system_init 
	clear
	while true;do
		source ./"$Hostname"
		read -p "select function : " res
		case $res in 
			0)
				LOGDIR=./logs/temp/`date "+%Y%m%d%H%M%S"`/
				mkdir -p $LOGDIR
				echo ""
				echo "Test Log Directory : ${LOGDIR}"
				echo "================="
				#chmod 777 ./factory_test.conf.default
				#source ./factory_test.conf.default $WIFI_AP_NAME $WIFI_AP_PASSWORD $WEBSERVER
				source ./automated.conf
				echo ""
				pause 'Press any key to continue interactive test'
				echo ""
				source ./interactive.conf
				pause 'Press any key to continue...'
				;;
			1)
				LOGDIR=./logs/temp/`date "+%Y%m%d%H%M%S"`/
				mkdir -p $LOGDIR
				echo ""
				echo "Test Log Directory : ${LOGDIR}"
				echo "================="
				source ./automated.conf
				pause 'Press any key to continue...'
				;;
			2)
				LOGDIR=./logs/temp/`date "+%Y%m%d%H%M%S"`/
				mkdir -p $LOGDIR
				echo ""
				echo "Test Log Directory : ${LOGDIR}"
				echo "================="
				source ./interactive.conf
				pause 'Press any key to continue...'
				;;
			3)
				run_test "[eMMC] - [eMMC Read\Write]" bin/emmc/test_emmc_read_write2.sh 
				pause 'Press any key to continue...'
				;;
			4)
				run_test "[SDcard] - [SDcard Read\Write]" bin/sdcard/test_sdcard_read_write_p1.sh "1"
				pause 'Press any key to continue...'
				;;
			5)
				run_test "[USB] - [USB DISK]" bin/usb/test_usb_disk.sh ""
				pause 'Press any key to continue...'
				;;
			6)
				run_test "[RJ45 eth0] - [GBE]" bin/net/test_eth_nv.sh  "eth0 1 3 192.168.0.99"
				pause 'Press any key to continue...'
				;;
			7)
				run_test "[RJ45 eth1] - [GBE]" bin/net/test_eth_nv.sh  "eth1 1 3 192.168.0.99"
				pause 'Press any key to continue...'
				;;
			8)
				run_test "[M.2] - [Key B - Detect Telit-le910c4]" bin/m2/test_m2_detect_telit-l3910c4.sh
				pause 'Press any key to continue...'
				;;
			9)
				run_test "[M.2] - [Key E - Detect AW-cb375nf]" bin/m2/test_m2_detect_aw-cb375nf.sh
				pause 'Press any key to continue...'
				;;
			10)
				run_test "[LED] - [Light Up]" bin/fb/test_hdmi_colorbar.sh
				pause 'Press any key to continue...'
				;;
			11)
				run_test "[HDMI] - [Show colorbar to HDMI]" bin/fb/test_hdmi_show_picture_fim.sh bin/fb/all.png
				pause 'Press any key to continue...'
				;;
			12)
				read -p "Enter mac addres (ex: 007D4000A267 ) : " mac
				read -p "Enter SOC number (186 : TX2-NX, 194 : XavierNX, 210 : Nano ) : " soc
				sudo ./bin/tools/eeprom ${soc} ${mac}
				pause 'Press any key to continue...'
				;;
			13)
				read -p "Enter mac addres (ex: D4E5F6123456 ) : " mac
				id=`lspci | grep I210 | awk '{print $1}'`
				if [ -z "$id" ]; then
					echo "Cannot found the I210 ethernet."
					exit 1
				fi
				setpci -s $id COMMAND=0007
				./bin/tools/EepromAccessTool -nic=1 -f=./bin/tools/Dev_Start_I210_Copper_NOMNG_8Mb_A2_3.25_0.03.hex -mac=$mac
				pause 'Press any key to continue...'
				;;
			Q|q|E|e)
				end_test
				echo 7 > /proc/sys/kernel/printk
				exit 0
				;;
			*)
				;;
		esac
	done
}

do_test
