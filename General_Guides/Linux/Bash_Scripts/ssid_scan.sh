#!/bin/bash
#Scans and reports found SSID's

sudo iwlist wlp4s0 scan | grep -i ESSID
exit 0
