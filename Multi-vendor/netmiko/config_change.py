#!/usr/bin/env python
from netmiko import ConnectHandler
from getpass import getpass

device = {
    "device_type": "cisco_ios",
    "host": "192.168.111.123",
    "username": "admin",
    "password": getpass(),
}

commands = ["logging buffered 100000"]
with ConnectHandler(**device) as net_connect:
    output = net_connect.send_config_set(commands)
    output += net_connect.save_config()

print()
print(output)
print()
