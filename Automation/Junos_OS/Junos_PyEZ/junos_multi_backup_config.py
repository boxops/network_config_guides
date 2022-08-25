"""
Purpose
Save the configuration of multiple devices.

Requirements
python -m pip install junos-eznc lxml

Usage
python3 junos_multi_backup_config.py
"""





from jnpr.junos import Device
from lxml import etree
import os

hosts = [
    "11.11.11.11",
    "11.11.11.12",
    "11.11.11.13",
    "11.11.11.14"
]

user = "admin"
password = "Super23Secure34Password!"
port = 22

online_hosts = []
offline_hosts = []
exception_errors = []

for host in hosts:
    ping = None
    ping = os.system(f"ping -n 2 {host}")
    if ping == 0:
        print(f"{host} is online.")
        online_hosts.append(host)
        filename = None
        filename = f"{host}.txt"
        try:
            with Device(host=host, user=user, password=password, port=port) as dev:
                data = dev.rpc.get_config(options={'format':'text'})
                config = etree.tostring(data, encoding='unicode', pretty_print=True)
                # print(config)
            with open(filename, "w+") as file:
                file.write(config)
        except Exception as e:
            print(e)
            exception_errors.append(e)
    else:
        print(f"{host} is offline.")
        offline_hosts.append(host)

print("---[ Online Hosts ]---)")
print(online_hosts)
print("---[ Offline Hosts ]---)")
print(offline_hosts)
print("---[ Exception Errors ]---)")
print(exception_errors)
