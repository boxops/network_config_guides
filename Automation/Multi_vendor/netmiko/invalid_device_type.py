#!/usr/bin/env python
from netmiko import ConnectHandler

cisco1 = {
    # Just pick an 'invalid' device_type
    "device_type": "invalid",
    "host": "192.168.111.1",
    "username": "admin",
    "password": "invalid",
}

# Print the available device types currently supported by Netmiko
net_connect = ConnectHandler(**cisco1)
net_connect.disconnect()
