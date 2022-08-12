#!/usr/bin/env python
from netmiko import SSHDetect, ConnectHandler
from getpass import getpass

device = {
    "device_type": "autodetect",
    "host": "192.168.111.123",
    "username": "admin",
    "password": getpass(),
}

guesser = SSHDetect(**device)
best_match = guesser.autodetect()
print(best_match)  # Name of the best device_type to use further
print(guesser.potential_matches)  # Dictionary of the whole matching result
# Update the 'device' dictionary with the device_type
device["device_type"] = best_match

with ConnectHandler(**device) as connection:
    print(connection.find_prompt())
