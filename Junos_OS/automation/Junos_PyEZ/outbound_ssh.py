import socket
from jnpr.junos import Device
from jnpr.junos.exception import ConnectError
from getpass import getpass
from pprint import pprint

"""
  Listen on TCP port 2200 for incoming SSH session with a device running Junos OS. 
  Upon connecting, collect and print the devices facts, 
  then disconnect from that device and wait for more connections.
  
  ## Outbound SSH Configuration on Juniper
  set system services outbound-ssh client outbound-ssh device-id
  set system services outbound-ssh client outbound-ssh secret Juniper123
  set system services outbound-ssh client outbound-ssh services netconf
  # Node to connect to
  set system services outbound-ssh client outbound-ssh 192.168.112.2 port 2200
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
