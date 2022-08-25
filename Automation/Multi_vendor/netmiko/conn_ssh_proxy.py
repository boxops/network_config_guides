#!/usr/bin/env python
from netmiko import ConnectHandler
from getpass import getpass


cisco1 = {
    "device_type": "cisco_ios",
    "host": "192.168.111.1",
    "username": "admin",
    "password": getpass(),
    "ssh_config_file": "~/.ssh/ssh_config",
}

with ConnectHandler(**cisco1) as net_connect:
    output = net_connect.send_command("show users")

print(f"\n{output}\n")
