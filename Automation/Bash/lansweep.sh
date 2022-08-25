#!/bin/bash

# Pingsweep the first IP address on all private networks with ping -c 1
# Write output to a file (e.g. ./pisweep > iplist.txt)

Class_A=10
Class_B=172
Class_C=192.168

for ipC in `seq 0 254`; do
	ping -c 1 $Class_C.$ipC.1 | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
	done

for ipB in `seq 16 31`; do
	for ipb in `seq 0 254`; do
		ping -c 1 $Class_B.$ipB.$ipb.1 | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
		done
	done

for ipA in `seq 0 255`; do
	for ipa in `seq 0 254`; do
		ping -c 1 $Class_A.$ipA.$ipa.1 | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
		done
	done
exit 0
