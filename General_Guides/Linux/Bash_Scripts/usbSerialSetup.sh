#! /bin/bash

# use this script to configure an USB to Serial cable port on Linux

VENDOR=$(lsusb | grep 'FT232 Serial' | cut -d " " -f 6 | cut -d ':' -f 1)
PRODUCT=$(lsusb | grep 'FT232 Serial' | cut -d " " -f 6 | cut -d ':' -f 2)

echo modprobe usbserial vendor="0x${VENDOR}" product="0x${PRODUCT}"

USB=$(dmesg | grep 'FTDI' | grep -o 'ttyUSB.' | tail -1)

sudo chmod 777 "/dev/${USB}"

# now connect to serial port or use putty
#cu -l "/dev/${USB}" -s 9600

# type ~. to quit
