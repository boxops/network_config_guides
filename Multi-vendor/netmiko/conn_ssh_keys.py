#!/usr/bin/env python
from netmiko import ConnectHandler

key_file = "~/.ssh/id_rsa"
cisco1 = {
    "device_type": "cisco_ios",
    "host": "192.168.111.1",
    "username": "admin",
    "use_keys": True,
    "key_file": key_file,
}

with ConnectHandler(**cisco1) as net_connect:
    output = net_connect.send_command("show ip arp")

print(f"\n{output}\n")
