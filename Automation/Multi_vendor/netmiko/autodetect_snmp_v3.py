# SNMPv3
import sys
from getpass import getpass
from netmiko.snmp_autodetect import SNMPDetect
from netmiko import ConnectHandler

host = "192.168.111.123"

device = {
    "host": host, 
    "username": "admin", 
    "password": getpass()
}

snmp_key = getpass("Enter SNMP community: ")
my_snmp = SNMPDetect(
    host,
    snmp_version="v3",
    user="pysnmp",
    auth_key=snmp_key,
    encrypt_key=snmp_key,
    auth_proto="sha",
    encrypt_proto="aes128",
)
device_type = my_snmp.autodetect()
print(device_type)

if device_type is None:
    sys.exit("SNMP failed!")

# Update the device_type with information discovered using SNMP
device["device_type"] = device_type
net_connect = ConnectHandler(**device)
print(net_connect.find_prompt())
net_connect.disconnect()
