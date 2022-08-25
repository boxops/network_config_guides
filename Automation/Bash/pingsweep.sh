#!/bin/bash

# Sweeps the network with ping -c 1
# Run the script with an argument e.g. (./pingsweep 192.168.1)
# Write output to a file e.g. (./pingsweep 192.168.1 > iplist.txt)

for ip in `seq 1 254`; do
	ping -c 1 $1.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
done
