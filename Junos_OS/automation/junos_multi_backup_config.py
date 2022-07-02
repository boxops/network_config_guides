# Requirements
# pip3 install junos-eznc lxml

# Usage
# python3 junos_get_config.py

from jnpr.junos import Device
from lxml import etree
import os

hosts = [
    "185.96.18.71", #HELA
    "185.96.18.45", #BENETT
    "185.96.18.49", #VALET
    "185.96.18.35", #TDA
    "185.96.18.37", #MARGOT
    "185.96.18.47", #LUMON
    "185.96.18.51", #LHH
    "185.96.18.89", #NAILS
    "185.96.18.65", #HURFORD
    "185.96.18.97", #TEACH
    "185.96.18.105", #CNET
    "185.96.18.107", #CNET
    "185.96.18.109", #CNET
    "185.96.18.115", #CNET
    "185.96.18.117", #CNET
    "185.96.18.119", #FERRA
    "185.96.18.211", #VAP4
    "185.96.18.217", #VAP2
    "185.96.18.241", #VIROCOM
    "185.96.18.169", #RON
    "185.96.18.59", #RON
    "185.96.18.75", #RON
    "185.96.18.61", #JACKSON
    "185.96.18.15", #HYTERA
    "185.96.18.31", #TBUK-HO-2
    "185.96.18.29", #TBUK-HO-1
    "185.96.18.55", #PEPKOR-HO-2
    "185.96.16.218", #ERCO
    "185.96.18.93", #TEACH
    "185.96.18.25", #ICLR
    "185.96.18.39", #HURFORD
    "185.96.18.87", #PEPKOR-HO-1
    "185.96.18.63", #APOLLO
    "185.96.18.95", #TEACH
    "185.96.18.99", #TEACH
    "91.109.47.22", #CNET
    "91.109.47.66", #CNET
    "91.109.47.86", #CNET
    "185.96.18.111", #CNET
    "91.109.47.14", #CNET
    "185.96.18.21", #FERRA
    "91.109.47.2", #CNET
    "91.109.47.122", #CNET
    "185.96.18.123", #RED
    "91.109.42.94", #MEGA
    "91.109.42.92" #MEGA
]

user = "netadmin"
password = "H3st1a3n!"
port = 22

online_hosts = []
offline_hosts = []
exception_errors = []

for host in hosts:
    ping = None
    ping = os.system("ping -n 2 " + host)
    if ping == 0:
        print(host + " is online.")
        online_hosts.append(host)
        filename = None
        filename = host + ".txt"
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
        print(host + " is offline.")
        offline_hosts.append(host)

print("---[ Online Hosts ]---)")
print(online_hosts)
print("---[ Offline Hosts ]---)")
print(offline_hosts)
print("---[ Exception Errors ]---)")
print(exception_errors)
