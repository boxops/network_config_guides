from jnpr.junos import Device
from lxml import etree
from getpass import getpass

host = '192.168.111.123'
user = 'admin'
password = "Juniper123" # getpass()
port = 22

# with Device(host=host, user=user, password=password, port=port) as dev:
#     data = dev.rpc.get_config(options={'format':'text'})
#     config = etree.tostring(data, encoding='unicode', pretty_print=True)
#     print(config)

with Device(host=host, user=user, password=password, port=port) as dev:
    data = dev.rpc.get_software_information({'format': 'json'})
    # print(data)

    # Print SRX hostname
    print(data['software-information'][0]['host-name'][0]['data'])
    # Print SRX version
    print(data['software-information'][0]['junos-version'][0]['data'])
