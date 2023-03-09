#!/usr/bin/python3
# Reference: https://librouteros.readthedocs.io/en/3.2.1/index.html

import os, ssl, json, librouteros


def creds():
    # import credentials from environment variables
    username = os.environ.get("ROUTEROS_USERNAME")
    password = os.environ.get("ROUTEROS_PASSWORD")

    return username, password


# Before connecting, the 'api-ssl' service must be enabled on routeros
# The code below allows connecting to the REST API without a ceritficate
def connect(host, encrypted=True, unencrypted=False):

    username, password = creds()

    if encrypted:
        ctx = ssl.create_default_context()
        ctx.check_hostname = False
        ctx.set_ciphers("ADH:@SECLEVEL=0")
        return librouteros.connect(
            username=username,
            password=password,
            host=host,
            ssl_wrapper=ctx.wrap_socket,
            port=8729,
        )

    elif unencrypted:
        return librouteros.connect(username=username, password=password, host=host)


# Get information about all interfaces
def get_all_interfaces():
    interfaces = api.path("interface")

    for interface in interfaces:
        print(json.dumps(interface, indent=4))


# Query specific information about interfaces
def simple_query():
    name = librouteros.query.Key("name")
    int_type = librouteros.query.Key("type")
    mac_address = librouteros.query.Key("mac-address")

    for row in api.path("/interface").select(name, int_type, mac_address):
        print(json.dumps(row, indent=4))


# Advanced query
# Adding 'where()', allows to fine tune the search criteria.
# The syntax is very similar to an SQL query.
def advanced_query():
    name = librouteros.query.Key("name")
    disabled = librouteros.query.Key("disabled")
    mac_address = librouteros.query.Key("mac-address")

    query = (
        api.path("/interface")
        .select(name, disabled, mac_address)
        .where(
            disabled == False,
            name.In("E2-D16", "E4-D49"),
        )
    )

    for row in query:
        print(json.dumps(row, indent=4))


if __name__ == "__main__":
    host = "172.16.1.1"

    api = connect(host=host, encrypted=True)

    get_all_interfaces()
    simple_query()
    advanced_query()
