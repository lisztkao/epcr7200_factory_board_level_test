echo 32 /sys/class/gpio/export
echo out >  /sys/class/gpio/gpio32/direction
echo 1 /sys/class/gpio/gpio32/value
echo 33 /sys/class/gpio/export
echo out >  /sys/class/gpio/gpio33/direction
echo 1 /sys/class/gpio/gpio33/value
 
 
run_test "[voltage test] - [voltage_ch1]" bin/voltage/test_voltage.sh  "/sys/devices/soc0/soc/2000000.aips-bus/2000000.spba-bus/2018000.ecspi/spi_master/spi4/spi4.1/iio:device0/in_voltage0_raw    0   50"
run_test "[voltage test] - [voltage_ch2]" bin/voltage/test_voltage.sh  "/sys/devices/soc0/soc/2000000.aips-bus/2000000.spba-bus/2018000.ecspi/spi_master/spi4/spi4.1/iio:device0/in_voltage1_raw 1950 2150"
run_test "[voltage test] - [voltage_ch3]" bin/voltage/test_voltage.sh  "/sys/devices/soc0/soc/2000000.aips-bus/2000000.spba-bus/2018000.ecspi/spi_master/spi4/spi4.1/iio:device0/in_voltage2_raw  710  810"
run_test "[voltage test] - [voltage_ch4]" bin/voltage/test_voltage.sh  "/sys/devices/soc0/soc/2000000.aips-bus/2000000.spba-bus/2018000.ecspi/spi_master/spi4/spi4.1/iio:device0/in_voltage3_raw  720  820"
run_test "[voltage test] - [voltage_ch5]" bin/voltage/test_voltage.sh  "/sys/devices/soc0/soc/2000000.aips-bus/2000000.spba-bus/2018000.ecspi/spi_master/spi4/spi4.1/iio:device0/in_voltage4_raw  720  820"
run_test "[voltage test] - [voltage_ch6]" bin/voltage/test_voltage.sh  "/sys/devices/soc0/soc/2000000.aips-bus/2000000.spba-bus/2018000.ecspi/spi_master/spi4/spi4.1/iio:device0/in_voltage5_raw   -1   50"
run_test "[voltage test] - [voltage_ch7]" bin/voltage/test_voltage.sh  "/sys/devices/soc0/soc/2000000.aips-bus/2000000.spba-bus/2018000.ecspi/spi_master/spi4/spi4.1/iio:device0/in_voltage6_raw 3220 3320"
run_test "[voltage test] - [voltage_ch8]" bin/voltage/test_voltage.sh  "/sys/devices/soc0/soc/2000000.aips-bus/2000000.spba-bus/2018000.ecspi/spi_master/spi4/spi4.1/iio:device0/in_voltage7_raw 1900 2000"
