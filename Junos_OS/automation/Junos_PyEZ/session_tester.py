# Purpose
# The following sample code prints the value of the connected property after connecting to a device running Junos OS and again after closing the session.

# Requirements
# python -m pip install junos-eznc lxml

# Usage
# python3 session_tester.py

# Reference
# https://www.juniper.net/documentation/us/en/software/junos-pyez/junos-pyez-developer/topics/topic-map/junos-pyez-connection-methods.html

from jnpr.junos import Device

dev = Device(host='router.example.net')

dev.open()
print (dev.connected)

dev.close()
print (dev.connected)
