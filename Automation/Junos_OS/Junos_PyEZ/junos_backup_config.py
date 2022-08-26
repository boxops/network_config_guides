"""
Purpose
Save the configuration of a device.

Requirements
python -m pip install junos-eznc lxml

Usage
python3 junos_backup_config.py
"""


from jnpr.junos import Device
from lxml import etree

host = "11.11.11.11"
user = "admin"
password = "Super23Secure34Password?"
port = 22
filename = f"{host}.txt"

with Device(host=host, user=user, password=password, port=port) as dev:
    # # XML format (default)
    # data = dev.rpc.get_config()
    # config = etree.tostring(data, encoding='unicode', pretty_print=True)

    # # Text format
    # data = dev.rpc.get_config(options={'format':'text'})
    # config = etree.tostring(data, encoding='unicode', pretty_print=True)

    # Junos OS set format
    data = dev.rpc.get_config(options={'format':'set'})
    config = etree.tostring(data, encoding='unicode', pretty_print=True)

    # # JSON format
    # config = dev.rpc.get_config(options={'format':'json'})

with open(filename, "w+") as file:
    file.write(config)
