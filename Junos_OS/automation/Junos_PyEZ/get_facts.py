# Reference: https://junos-pyez.readthedocs.io/en/2.6.4/jnpr.junos.facts.html

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
