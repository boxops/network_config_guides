# Requirements
# pip3 install junos-eznc lxml

# Usage
# python3 junos_get_config.py

from jnpr.junos import Device
from lxml import etree

host = "185.96.18.45"
user = "netadmin"
password = "H3st1a3n!"
port = 22
filename = host + ".txt"

with Device(host=host, user=user, password=password, port=port) as dev:
    data = dev.rpc.get_config(options={'format':'text'})
    config = etree.tostring(data, encoding='unicode', pretty_print=True)
    # print(config)

with open(filename, "w+") as file:
    file.write(config)
