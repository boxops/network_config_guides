"""
Purpose
Establish a NETCONF session over SSH with the device’s management interface 

Requirements
python -m pip install junos-eznc lxml

Usage
python ssh_connection.py

Reference
https://www.juniper.net/documentation/us/en/software/junos-pyez/junos-pyez-developer/topics/topic-map/junos-pyez-connection-methods.html

Inbound SSH Configuration on Juniper
set system login user admin class super-user authentication plain-text-password
New password:
set system services ssh
"""

import sys
from getpass import getpass
from jnpr.junos import Device
from jnpr.junos.exception import ConnectError

hostname = input("Device hostname: ")
junos_username = input("Junos OS username: ")
junos_password = getpass("Junos OS or SSH key password: ")

try:
    with Device(host=hostname, user=junos_username, passwd=junos_password) as dev:   
        print (dev.facts)
except ConnectError as err:
    print ("Cannot connect to device: {0}".format(err))
    sys.exit(1)
except Exception as err:
    print (err)
    sys.exit(1)

"""
Junos PyEZ automatically queries the default SSH configuration file at ~/.ssh/config, if one exists. 
However, starting with Junos PyEZ Release 1.2, you can specify a different SSH configuration file when you create the device instance by including the ssh_config parameter in the Device argument list. For example:

ssh_config_file = "~/.ssh/config_dc"
dev = Device(host='198.51.100.1', ssh_config=ssh_config_file)
"""
