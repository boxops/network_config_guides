#!/usr/bin/env python
from netmiko import ConnectHandler
from getpass import getpass

device1 = {
    "device_type": "juniper_junos",
    "host": "192.168.111.123",
    "username": "admin",
    "password": "Juniper123" # getpass()
}

# File in same directory as script that contains
#
# $ cat config_changes.txt
# --------------
# line console 0
# logging sync

cfg_file = "config_changes.txt"
with ConnectHandler(**device1) as net_connect:
    output = net_connect.send_config_from_file(cfg_file)
    output += net_connect.save_config()

print()
print(output)
print()
