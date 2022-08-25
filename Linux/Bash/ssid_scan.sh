#!/bin/bash
# Scans and reports found SSIDs

sudo iwlist wlp4s0 scan | grep -i ESSID
exit 0
