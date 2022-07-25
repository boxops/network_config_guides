# Requirements
# pip3 install junos-eznc lxml

# Usage
# python3 junos_backup_config.py

from jnpr.junos import Device
from lxml import etree

host = "11.11.11.11"
user = "admin"
password = "Super23Secure34Password?"
port = 22
filename = host + ".txt"

with Device(host=host, user=user, password=password, port=port) as dev:
    data = dev.rpc.get_config(options={'format':'text'})
    config = etree.tostring(data, encoding='unicode', pretty_print=True)
    # print(config)

with open(filename, "w+") as file:
    file.write(config)
