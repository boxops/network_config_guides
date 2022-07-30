"""
Purpose
Configure a device running Junos OS to initiate a TCP/IP connection with a client management application 

Requirements
python -m pip install junos-eznc lxml

Usage
python3 outbound_ssh_connection.py

Reference
https://www.juniper.net/documentation/us/en/software/junos-pyez/junos-pyez-developer/topics/topic-map/junos-pyez-connection-methods.html#id-connecting-to-a-device-using-outbound-ssh

To configure the device running Junos OS for outbound SSH connections, include the outbound-ssh statement at the [edit system services] hierarchy level. 
In the following example, the device running Junos OS attempts to initiate a connection with the host at 198.51.100.101 on port 2200:
user@router1> show configuration system services outbound-ssh
  client outbound-ssh {
    device-id router1;
    secret "$9$h1/ceWbs4UDkGD/Cpu1I-Vb"; ## SECRET-DATA
    services netconf;
    198.51.100.101 port 2200;
  }
"""

import socket
from jnpr.junos import Device
from jnpr.junos.exception import ConnectError
from getpass import getpass
from pprint import pprint

"""
Listen on TCP port 2200 for incoming SSH session with a device running Junos OS. 
Upon connecting, collect and print the devices facts, 
then disconnect from that device and wait for more connections.
"""

def launch_junos_proxy(client, addr):
    val = {
            'MSG-ID': None,
            'MSG-VER': None,
            'DEVICE-ID': None
            }
    msg = ''
    count = 3
    while len(msg) < 100 and count > 0:
        c = client.recv(1)
        if c == '\r':
            continue

        if c == '\n':
            count -= 1
            if msg.find(':'):
                (key, value) = msg.split(': ')
                val[key] = value
                msg = ''
        else:
            msg += str(c)

    print('MSG %s %s %s' %
            (val['MSG-ID'], val['MSG-VER'], val['DEVICE-ID']))

    return client.fileno()


def main():
    
    PORT = 2200

    junos_username = input('Junos OS username: ')
    junos_password = getpass('Junos OS password: ')

    s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)

    s.bind(('', PORT))
    s.listen(5)
    print('\nListening on port %d for incoming sessions ...' % (PORT))

    sock_fd = 0    
    while True:
        client, addr = s.accept()
        print('\nGot a connection from %s:%d' % (addr[0], addr[1]))
        sock_fd = launch_junos_proxy(client, addr)

        print('Logging in ...')
        try:
            with Device(host=None, sock_fd=sock_fd, user=junos_username, passwd=junos_password) as dev:
                pprint(dev.facts)
        except ConnectError as err:
            print ("Cannot connect to device: {0}".format(err))                

if __name__ == "__main__":
    main()

