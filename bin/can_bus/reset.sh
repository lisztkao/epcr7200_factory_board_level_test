#!/bin/sh

[ -d /sys/class/gpio/gpio5 ]|| echo 5 > /sys/class/gpio/export
echo "out" > /sys/class/gpio/gpio5/direction
echo 0 > /sys/class/gpio/gpio5/value
usleep 300000
echo 1 > /sys/class/gpio/gpio5/value
