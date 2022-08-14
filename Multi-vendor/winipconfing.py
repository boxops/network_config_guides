'''
Run in admin mode

python .\winipconfing.py

netsh interface ip set address name= "Network Interface Name" static [IP address] [Subnet Mask] [Gateway].
Replace [IP address] [Subnet Mask] [Gateway] with the ones that match your network configuration.
'''

import os

interface = "Ethernet"
ip = "192.168.1.200"
subnet = "255.255.255.0"
gateway = "192.168.1.254"
primary_dns = "8.8.8.8"
# secondary_dns = "8.8.4.4"

def ip_config():
    try:
        # netsh interface ip set address name="Ethernet" static [IP address] [Subnet Mask] [Gateway]
        os.system("netsh interface ip set address name=\"{}\" static {} {} {}".format(interface, ip, subnet, gateway))

        # netsh interface ip set dns "Ethernet" static 8.8.8.8
        # os.system("netsh interface ip set dns \"{}\" static {}".format(interface, primary_dns))

        # netsh interface ip set dns "Ethernet" dhcp
        os.system("netsh interface ip set dns \"{}\" dhcp".format(interface))
    except Exception as e:
        print(e)

ip_config()


'''
Other useful commands

netsh interface ipv4 show ?
netsh interface ipv4 show route
netsh interface ipv4 show config
netsh interface ipv4 show neighbors


Configure IP with ipconfig

ipconfig /ip 10.0.0.101 255.255.255.0
ipconfig /dg 10.0.0.1

'''

