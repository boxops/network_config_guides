import sys
from getpass import getpass
from netmiko.snmp_autodetect import SNMPDetect
from netmiko import ConnectHandler

host = "192.168.111.1"
device = {"host": host, "username": "admin", "password": getpass()}

snmp_community = getpass("Enter SNMP community: ")
my_snmp = SNMPDetect(host, snmp_version="v2c", community=snmp_community)
device_type = my_snmp.autodetect()
print(device_type)

if device_type is None:
    sys.exit("SNMP failed!")

# Update the device dictionary with the device_type and connect
device["device_type"] = device_type
with ConnectHandler(**device) as net_connect:
    print(net_connect.find_prompt())
