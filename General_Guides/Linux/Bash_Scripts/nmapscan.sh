#!/bin/bash
#Run with iplist.txt

port=161
for ip in $(cat iplist.txt); do
	nmap -p $port -T4 $ip | grep -e "Nmap scan report" -e $port"/tcp" &
done
