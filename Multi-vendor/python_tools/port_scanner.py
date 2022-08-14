#!/usr/bin/env python3

# Example usage:
# python port_scanner.py 127.0.0.1

import sys
import socket
from datetime import datetime

def banner():
    print("PORT SCANNER")

def portscanner():

    if len(sys.argv) == 2:
        target = socket.gethostbyname(sys.argv[1])
    else:
        print("Please enter ip of the traget")

    print("*" * 50)
    print("Scanning Target: " + target)
    print("Scanning Start: " + str(datetime.now()))
    print("-" * 50)

    try:
        for port in range(1, 65535):
            s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            socket.setdefaulttimeout(1)

            result = s.connect_ex((target, port))
            if result == 0:
                print("{} Port {} is open".format(datetime.now(), port))
            s.close()
    except KeyboardInterrupt:
        print("\nScanning Stopped!")
        print("*" * 50)
        sys.exit()
    except socket.gaierror:
        print("\n Hostname could not be resolved!")
        print("*" * 50)
        sys.exit()
    except socket.error:
        print("\nCheck Internet connection.")
        print("*" * 50)
        sys.exit()

if __name__ == "__main__":
    portscanner()
