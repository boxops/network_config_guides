#!/usr/bin/env python
from getpass import getpass
from pprint import pprint
from netmiko import ConnectHandler
# Please PIP install both Genie and PyATS:
# pip install genie
# pip install pyats

device = {
    "device_type": "cisco_ios",
    "host": "192.168.111.1",
    "username": "admin",
    "password": getpass(),
}

with ConnectHandler(**device) as net_connect:
    output = net_connect.send_command("show ip interface brief", use_genie=True)

print()
pprint(output)
print()
