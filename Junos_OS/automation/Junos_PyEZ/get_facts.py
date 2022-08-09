from jnpr.junos import Device
from getpass import getpass

host = '192.168.111.123'
user = 'admin'
password = getpass()
port = 22

with Device(host=host, user=user, password=password, port=port) as dev:
    hostname = dev.facts['hostname']
    islinux = dev.facts['_is_linux']
    current_re = dev.facts['current_re']
    domain = dev.facts['domain']
    junos_info = dev.facts['junos_info']
    personality = dev.facts['personality']
    RE0 = dev.facts['RE0']
    version = dev.facts['version']
    virtual = dev.facts['virtual']
    print(hostname)
