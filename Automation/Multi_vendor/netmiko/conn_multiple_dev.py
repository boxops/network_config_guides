#!/usr/bin/env python
from netmiko import ConnectHandler
from getpass import getpass

# password = getpass()

cisco1 = {
    "device_type": "cisco_ios",
    "host": "192.168.111.1",
    "username": "admin",
    "password": "Cisco123" # password
}

srx1 = {
    "device_type": "juniper_junos",
    "host": "192.168.111.123",
    "username": "admin",
    "password": "Juniper123" # password
}

for device in (cisco1, srx1):
    net_connect = ConnectHandler(**device)
    print(net_connect.find_prompt())
    net_connect.disconnect()
