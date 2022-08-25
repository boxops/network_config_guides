#!/usr/bin/env python3

# imports
import argparse
import requests, json
import sys
from sys import argv
import os

# parser
parser = argparse.ArgumentParser()

parser.add_argument("-v", help="target/host IP address", type=str, dest='target', required=True)

args = parser.parse_args()


# colors
red = '\033[31m'
yellow = '\033[93m'
lgreen = '\033[92m'
clear = '\033[0m'
bold = '\033[01m'
cyan = '\033[96m'

# banner
def banner():
    print(f"{red}IP TRACER")


banner()

ip = args.target

api = "http://ip-api.com/json/"

try:
    data = requests.get(api+ip).json()
    sys.stdout.flush()
    a = lgreen+bold+"[$]"
    b = cyan+bold+"[$]"
    print (a, "[Victim]:", data['query'])
    print(f"{red}<--------------->{red}")
    print (b, "[ISP]:", data['isp'])
    print(f"{red}<--------------->{red}")
    print (a, "[Organisation]:", data['org'])
    print(f"{red}<--------------->{red}")
    print (b, "[City]:", data['city'])
    print(f"{red}<--------------->{red}")
    print (a, "[Region]:", data['region'])
    print(f"{red}<--------------->{red}")
    print (b, "[Longitude]:", data['lon'])
    print(f"{red}<--------------->{red}")
    print (a, "[Latitude]:", data['lat'])
    print(f"{red}<--------------->{red}")
    print (b, "[Time zone]:", data['timezone'])
    print(f"{red}<--------------->{red}")
    print (a, "[Zip code]:", data['zip'])
    print(f" {yellow}")

except KeyboardInterrupt:
    print(f'Terminating, Bye{lgreen}')
    sys.exit(0)
except requests.exceptions.ConnectionError as e:
    print(f"{red}[~] check your internet connection!{clear}")
sys.exit(1)
