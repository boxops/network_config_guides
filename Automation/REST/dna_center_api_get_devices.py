#!/usr/bin/env python

# Modules import
import requests
from requests.auth import HTTPBasicAuth

# Disable SSL warnings. Not needed in production environments with valid certificates
import urllib3
urllib3.disable_warnings()

# Authentication
BASE_URL = 'https://sandboxdnac.cisco.com'
AUTH_URL = '/dna/system/api/v1/auth/token'
USERNAME = 'devnetuser'
PASSWORD = 'Cisco123!'
DEVICES_URL = '/dna/intent/api/v1/network-device'

response = requests.post(BASE_URL + AUTH_URL, auth=HTTPBasicAuth(USERNAME, PASSWORD), verify=False)
token = response.json()['Token']

# Get count of devices
headers = {'X-Auth-Token': token, 'Content-Type': 'application/json'}
DEVICES_COUNT_URL = '/dna/intent/api/v1/network-device/count'
response = requests.get(BASE_URL + DEVICES_COUNT_URL,
                        headers=headers, verify=False)

def get_count():
    # Print device count
    print(response.json()['response'])

def get_devices():
    # Get list of devices
    response = requests.get(BASE_URL + DEVICES_URL, headers=headers, verify=False)

    # Print id, hostname and management IP
    for item in response.json()['response']:
        print(item['id'], item['hostname'], item['platformId'], item['managementIpAddress'])

def filter_by_platform():
    # Filter devices by platform ID
    query_string_params = {'platformId': 'AIR-CT3504-K9'}
    response = requests.get(BASE_URL + DEVICES_URL, headers=headers,
                            params=query_string_params, verify=False)
    for item in response.json()['response']:
        print(item['hostname'], item['managementIpAddress'])

def filter_by_hostname():
    # Filter devices by hostname, get one result
    query_string_params = {'hostname': 'c3504.abc.inc'}
    response = requests.get(BASE_URL + DEVICES_URL, headers=headers,
                            params=query_string_params, verify=False)
    device_id = response.json()['response'][0]['id']

    # Get information from one device
    DEVICES_BY_ID_URL = '/dna/intent/api/v1/network-device/'
    response = requests.get(BASE_URL + DEVICES_BY_ID_URL + device_id,
                            headers=headers, verify=False)
    print(response.json()['response'])

def main():
    get_devices()

if __name__ == "__main__":
    main()
