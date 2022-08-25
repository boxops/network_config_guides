#! /bin/bash

# Configure a USB to Serial (console cable) port on Linux and connect to networking devices
# Usage: sudo ./usb_serial_setup.sh

VENDOR=$(lsusb | grep 'FT232 Serial' | cut -d " " -f 6 | cut -d ':' -f 1)
PRODUCT=$(lsusb | grep 'FT232 Serial' | cut -d " " -f 6 | cut -d ':' -f 2)

echo modprobe usbserial vendor="0x${VENDOR}" product="0x${PRODUCT}"

USB=$(dmesg | grep 'FTDI' | grep -o 'ttyUSB.' | tail -1)

sudo chmod 777 "/dev/${USB}"

# Now connect the cable to the serial port on the networking device
# cu -l "/dev/${USB}" -s 9600

# type ~. to quit
