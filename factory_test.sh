#!/bin/sh 

#/home/root/advtest/factory
Ver=0.1.6
LANG=C
LANGUAGE="en_US.UTF-8"

Hostname=`cat /etc/hostname`

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
		source	./"$Hostname"

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
				run_test "[eMMC] - [eMMC Read\Write]" bin/emmc/test_emmc_read_write.sh "1"
				pause 'Press any key to continue...'
				;;
			4)
				if [[ "$Hostname" == "magmon-imx6q-dms-ba16" ]]; then
					run_test "[SDcard] - [SDcard detection]" bin/sdcard/test_sdcard_detection2.sh ""
			    else
					run_test "[SDcard] - [SDcard detection]" bin/sdcard/test_sdcard_detection.sh ""
			    fi
				pause 'Press any key to continue...'
				;;
			5)
				run_test "[SDcard] - [SDcard Read\Write]" bin/sdcard/test_sdcard_read_write.sh "1"
				pause 'Press any key to continue...'
				;;
			6)
				run_test "[SATA] - [SATA Read\Write]" bin/sata/test_sata_read_write.sh "1"
				pause 'Press any key to continue...'
				;;
			7)
				run_test "[USB Ports] - [USB Ports detection]" bin/usb/test_usb_ports_detection.sh ""
				pause 'Press any key to continue...'
				;;
			8)
				run_test "[MINI USB] - [MINI USB detection]" bin/usb/test_mini_usb_detection.sh ""
				pause 'Press any key to continue...'
				;;
			9)
				run_test "[GPIO] - [CN25 DB9 GPIO ports input\output]" bin/gpio/test_gpio_input_output.sh "CN25"
				pause 'Press any key to continue...'
				;;
			10)
				run_test "[GPIO] - [CN28 GPIO ports input\output]" bin/vpm/test_vpm_battery.sh ""
				pause 'Press any key to continue...'
				;;
			11)
				run_test "[GPIO] - [CN28 GPIO pcie_ports input\output]" bin/gpio/test_gpio_pcie_ports.sh ""
				pause 'Press any key to continue...'
				;;
			12)
				run_test "[GPIO] - [Power input detection]" bin/gpio/test_gpio_power_port.sh ""
				pause 'Press any key to continue...'
				;;
			13)
				if [[ "$Hostname" == *"imsse01"* ]]; then
					run_test "[RJ45 GBE] - [GBE]" bin/net/test_eth.sh "enp1s0 5"
				elif [[ "$Hostname" == *"dmsse23"* ]]; then
					run_test "[RJ45 GBE] - [GBE]" bin/net/test_eth.sh "eth0 5"
				elif [[ "$Hostname" == "magmon-imx6q-dms-ba16" ]]; then
					ifconfig eth1 down
					run_test "[RJ45 eth0] - [GBE]" bin/net/test_eth2.sh  "eth0 1 3 192.168.0.99"
				else
					run_test "[RJ45 GBE] - [GBE]" bin/net/test_eth.sh "eth0 5"
			    fi
				pause 'Press any key to continue...'
				;;
			14)
				run_test "[RTC] - [RTC time set\get]" bin/rtc/test_rtc_set_get.sh "$NTPSERVER"
				pause 'Press any key to continue...'
				;;
			15)
				run_test "[PCIe] - [PCIe device detection]" bin/pcie/test_pcie_device_detection.sh ""
				pause 'Press any key to continue...'
				;;	
			16)
				run_test "[Audio] - [Audio input\output]" bin/audio/test_audio_input_output.sh ""
				pause 'Press any key to continue...'
				;;
			17)
				run_test "[LVDS] - [Play video to LVDS]" bin/fb/test_lvds_play_video.sh "/home/root/video/1.mp4"
				pause 'Press any key to continue...'
				;;
			18)
				run_test "[LVDS] - [Show picture to LVDS]" bin/fb/test_lvds_show_picture.sh "bin/fb/1.png"
				pause 'Press any key to continue...'
				;;
			19)
				run_test "[HDMI] - [Show picture to HDMI]" bin/fb/test_hdmi_show_picture.sh "bin/fb/1.png"
				pause 'Press any key to continue...'
				;;
			20)
				run_test "[UART] - [HW CTS\RTS flow control Send]" bin/uart/test_uart_flow_control.sh "/dev/ttymxc2"
				pause 'Press any key to continue...'
				;;
			21)
				run_test "[UART] - [HW CTS\RTS flow control Receive]" bin/uart/test_uart_flow_control.sh "/dev/ttymxc2"
				pause 'Press any key to continue...'
				;;
			22)
				run_test "[WDT] - [WDOUT]"  bin/wdt/test_wdt_wdout.sh ""
				pause 'Press any key to continue...'
				;;
			23)
				run_test "[I2C EEPROM] - [U29 I2C EEPROM]" bin/eeprom/test_i2c_eeprom.sh ""
				pause 'Press any key to continue...'
				;;
			24)
				run_test "[SPI EEPROM] - [U10 SPI EEPROM]" bin/eeprom/test_spi_eeprom.sh ""
				pause 'Press any key to continue...'
				;;
			25)
				if [[ "$Hostname" == *"imsse01"* ]]; then
					run_test "[NOR Flash] - [NOR Flash Erase\Write]" bin/mtd/test_nor_flash_erase_write2.sh "/dev/mtd2 /dev/mtdblock2"
				elif [[ "$Hostname" == *"dmsse23"* ]]; then
					run_test "[NOR Flash] - [NOR Flash Erase\Write]" bin/mtd/test_nor_flash_erase_write2.sh "/dev/mtd2 /dev/mtdblock2"
				else
					run_test "[NOR Flash] - [NOR Flash Erase\Write]" bin/mtd/test_nor_flash_erase_write2.sh "/dev/mtd0 /dev/mtdblock0"
				fi
				pause 'Press any key to continue...'
				;;
			26)
				run_test "[NOR Flash] - [NOR Flash Erase]" bin/mtd/test_nor_erase.sh ""
				pause 'Press any key to continue...'
				;;
			27)
				run_test "[NOR Flash] - [Write Serial Number]" bin/mtd/test_write_serial.sh ""
				pause 'Press any key to continue...'
				;;
			28)
				run_test "[VPM] - [Write Serial Number]" bin/vpm/test_vpm_battery.sh ""
				pause 'Press any key to continue...'
				;;
			29)
				run_test "[VPM] - [Write Serial Number]" bin/vpm/test_vpm_hotkey.sh ""
				pause 'Press any key to continue...'
				;;
				
			30)
				run_test "[Buzzer] - [Play Buzzer]" bin/buzzer/test_buzzer.sh ""
				pause 'Press any key to continue...'
				;;
			31)
				if [[ "$Hostname" == *"imsse01"* ]]; then
					run_test "[Wifi] - [scan connet ping test]" bin/net/test_wlan_dbm.sh "wlan0 WiFiTest-4FT2E 1C1F9289BA0A0A0EAA111785AB 0 -80 192.168.1.1 0x10 WEP 0"
				else
					run_test "[Wifi] - [scan connet ping test]" bin/net/test_wlan_connectio.sh "wlan0 nl80211"
				fi

				pause 'Press any key to continue...'
				;;
			32)
				run_test "[Wifi] - [scan connet ping test]" bin/net/test_bt_detection.sh
				pause 'Press any key to continue...'
				;;
				
			33)
				if [[ "$Hostname" == *"imsse01"* ]]; then
					run_test "[Light Sensor] - [Light Sensor Read]" bin/lightsensor/test_lightsensor2.sh "/sys/bus/i2c/drivers/opt3001/0-0044/iio:device0/enable /sys/bus/i2c/drivers/opt3001/0-0044/iio:device0/lux"
				elif [[ "$Hostname" == *"dmsse23"* ]]; then
					run_test "[Light Sensor] - [Light Sensor Read]" bin/lightsensor/test_lightsensor2.sh "/sys/devices/soc0/soc/2100000.aips-bus/21a8000.i2c/i2c-2/2-0029/iio:device0/events/in_intensity_both_thresh_rising_en /sys/devices/soc0/soc/2100000.aips-bus/21a8000.i2c/i2c-2/2-0029/iio:device0/lux"
				else
					run_test "[Light Sensor] - [Light Sensor Read]" bin/lightsensor/test_lightsensor.sh ""
				fi
				pause 'Press any key to continue...'
				;;
			34)
				read -p "Please input BoradR-Reach slave(1) or master(0): " HOST_OR_SLAVE
				run_test "[BoardR-reach] - [BoardR-reach Connection]" bin/boradr-reach/boradr-reach.sh "eth0 5 $HOST0_boardR_IP  
$eth0_boardR_IP $HOST_OR_SLAVE"
				pause 'Press any key to continue...'
				;;
			35)
				run_test "[Wifi BT LED] - [led test]" bin/net/test_led.sh ""
				pause 'Press any key to continue...'
				;;
			36)
				run_test "[Current Sense] - [VPM Backlight Current Sense]" bin/vpm/test_vpm_backlight_current.sh ""
				pause 'Press any key to continue...'
				;;
			37)
				ifconfig eth0 down
				run_test "[RJ45 eth1] - [GBE]" bin/net/test_eth2.sh  "eth1 0 5 192.168.0.99"
				pause 'Press any key to continue...'
				;;
			38)
				run_test "[spi test] - [spi]" bin/spi/test_spi.sh  "/dev/spidev4.0"
				pause 'Press any key to continue...'
				;;
			39)
				run_test "[mag_off test] - [mag_off]" bin/spi/test_mag_off.sh  "/dev/spidev4.0"
				pause 'Press any key to continue...'
				;;
			40)
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq call_Insite"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Service_Mode"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Fill_Mode"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq No"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Date"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Alarms"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Home"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Up"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Down"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Yes"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq Sample"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq 1"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq 2"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq 3"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq 4"
				run_test "[keypad test] - [keypad]" bin/gpio/test_interrupt.sh  "magmon-keypad-irq 5"
				pause 'Press any key to continue...'
				;;
			41)
				run_test "[SPI_LCD test] - [SPI_LCD]" bin/spi/test_spi_lcd.sh  "/dev/spidev4.0"
				pause 'Press any key to continue...'
				;;
			42)
				run_test "[SPI_LED test] - [SPI_LED]" bin/spi/test_spi_led.sh  "/dev/spidev4.0"
				pause 'Press any key to continue...'
				;;
			43)
				source ./bin/voltage/test_voltage_channel1.sh
				pause 'Press any key to continue...'
				;;
			44)
				source ./bin/voltage/test_voltage_channel2.sh
				pause 'Press any key to continue...'
				;;
			45)
				source ./bin/voltage/test_voltage_channel3.sh
				pause 'Press any key to continue...'
				;;
			46)
				source ./bin/voltage/test_voltage_channel4.sh
				pause 'Press any key to continue...'
				;;
			47)
				run_test "[USB_SD test] - [USB_SD Read and Write]" bin/usb/test_usb_sdcard.sh ""
				pause 'Press any key to continue...'
				;;
			48)
				run_test "[Wifi] - [wifi detection]" bin/net/test_wifi_detection.sh "wlan0"
				pause 'Press any key to continue...'
				;;
			49)
				run_test "[COM] - [COM PORT LOOPBACK]" bin/comport/test_comport_loopback.sh "ttyUSB1"
				;;
			50)
				run_test "[Wifi] - [RSSI test]" bin/net/test_wlan_dbm.sh "wlan0 Linkou_RF null 0 -75 192.168.1.1 0x0 WPA 10"
				pause 'Press any key to continue...'
				;;
			51)
				run_test "[CAN bus] - [CAN bus Read and Erite]" bin/can_bus/test_can_bus.sh ""
				pause 'Press any key to continue...'
				;;
			52)
				run_test "[CAN gyro] - [CAN gyro Read]" bin/can_bus/test_can_bus_gyro.sh ""
				pause 'Press any key to continue...'
				;;
			53)
				run_test "[CAN1 loop CAN2] - [CAN1 loop CAN2d]" bin/can_bus/test_can_bus_loop.sh ""
				pause 'Press any key to continue...'
				;;
			54)
				run_test "[Touch] - [Touch panel drag and draw]" bin/touch/test_touch.sh ""
				pause 'Press any key to continue...'
				;;
			55)
				read -p "Please input MAC1 address: " WRITE_DATA1
	            read -p "Please input MAC2 address: " WRITE_DATA2
				run_test "[SPI MAC] - [Check SPI MAC Address]" bin/spi/test_spi_check_mac.sh "$WRITE_DATA1 $WRITE_DATA2"
				pause 'Press any key to continue...'
				;;
			56)
				run_test "[BT] - [ping test]" bin/net/test_bt_ping.sh "hci0 F8:94:C2:8F:F8:C1 5"
				pause 'Press any key to continue...'
				;;
			57)
				run_test "[3D] - [3D opengl2 test]" bin/3d/test_opengl2_3d.sh
				pause 'Press any key to continue...'
				;;
			58)
				run_test "[3D] - [3D opengl3 test]" bin/3d/test_opengl3_3d.sh
				pause 'Press any key to continue...'
				;;
			94)
				run_test "[CONFIG] - [WiFi MAC]" bin/spi/test_spi_mac.sh "/sys/class/spi_master/spi0/spi0.0/wifi_mac"
				pause 'Press any key to continue...'
				;;
			95)
				run_test "[CONFIG] - [BT MAC]" bin/spi/test_spi_mac.sh "/sys/class/spi_master/spi0/spi0.0/bt_mac"
				pause 'Press any key to continue...'
				;;
			96)
				if [[ "$Hostname" == "magmon-imx6q-dms-ba16" ]]; then
					read -p "Please input MAC1 address: " WRITE_DATA1
	                read -p "Please input MAC2 address: " WRITE_DATA2
					run_test "[CONFIG] - [Ethernet MAC]" bin/spi/test_spi_write_mac_python.sh "$WRITE_DATA1 $WRITE_DATA2"
				else
					run_test "[CONFIG] - [Ethernet1 MAC]" bin/spi/test_spi_mac.sh "/sys/class/spi_master/spi0/spi0.0/eth1_mac"
			    fi
				pause 'Press any key to continue...'
				;;
			97)
				run_test "[CONFIG] - [Ethernet0 MAC]" bin/spi/test_spi_mac.sh "/sys/class/spi_master/spi0/spi0.0/eth_mac"
				pause 'Press any key to continue...'
				;;
			98)
				if [[ "$Hostname" == "magmon-imx6q-dms-ba16" ]]; then
					read -p "Please input serial number: " WRITE_DATA
					run_test "[CONFIG] - [Serial number]" bin/spi/test_spi_write_sn_python.sh "$WRITE_DATA"
				else
					run_test "[CONFIG] - [Serial number]" bin/spi/test_spi_write.sh "/sys/class/spi_master/spi0/spi0.0/serial_number"
				fi
				pause 'Press any key to continue...'
				;;
			99)
				run_test "[CONFIG] - [Board number]" bin/spi/test_spi_write.sh "/sys/class/spi_master/spi0/spi0.0/board_number"
				pause 'Press any key to continue...'
				;;
			100)
				read -p "Please input battery serial number: " BATT_SN
				run_test "[CONFIG] - [Battery SN]" bin/vpm/test_vpm_battery_sn.sh "$BATT_SN"
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
