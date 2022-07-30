#! /usr/bin/python

# Perform necessary imports
from jnpr.junos import Device
from lxml.etree import dump, _Element
from sys import argv

# Use 1st command-line parameter as XPath, or use "." if it is not provided
conf_xpath = argv[1] if len(argv) > 1 else "."

# Username, password and device IP
USER = "lab"
PASSWD = "lab123"
DEVICE_IP = "172.25.11.1"

# Open NETCONF connection using PyEZ Device class
with Device(host=DEVICE_IP, user=USER, password=PASSWD) as dev:
    # Read a complete config using <get-config> RPC
    full_config = dev.rpc.get_config()
    # Filter the config with provided XPath
    filtered_config = full_config.xpath(conf_xpath)
    # The result of applying XPath is a list - perform for each loop
    for entry in filtered_config:
        # For each entry, print it either using dump() or print() functions
        if type(entry) is _Element:
          dump(entry)
        else:
          print(entry)
