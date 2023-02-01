#!/bin/sh
#restarts Wi-fi script

sel=3

sudo modprobe -r rtl8723de && sleep 5 && sudo modprobe rtl8723de ant_sel=$sel

exit 0

