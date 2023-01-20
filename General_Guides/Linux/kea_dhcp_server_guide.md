KEA DHCP Server Guide
=====================

### Kea DHCP Documentation

https://kea.readthedocs.io/en/latest/arm/intro.html

### What is Kea DHCP

- A modern DHCPv4 and DHCPv6 server
- Open Source (MPL License)
- JSON/REST API
- Modular design
- High performance (> 1000 leases/second with SQL database backend)
- Failover via SQL DB or High-Availability-Hook
- Host reservation support
- Support for DHCPv6 prefix delegation
- Dynamic reconfiguration
- Dynamic DNS updates
- SQL database backend (MySQL / PostgreSQL / Cassandra )
- Statistics module
- PXE Boot support

### Kea DHCP requirements

Kea requires to run:
- a cryptographic library: Botan or OpenSSL
- log4cplus C++ logging library
- the Boost C++ sstem library

Optional components:
- a database such as MySQL, PostgreSQL or Cassandra (CQL)
- FreeRadius-client library for Radius support
- Sysrepo for NETCONF support

### Kea DHCP installation via operating system packages

Kea DHCP is available in the package repositories of all major Linux and Unix systems.

If you have support from the OS vendor, installing from the OS repositories is the best choice.

Kea DHCP can also be installed from source, if you need a special build configuration or the latest features not available in the binary packages.

### Kea DHCP installation via ISC packages

ISC offers binary packages of Kea DHCP for users hosted on Cloudsmith.

If you need the latest Kea version, these packages are an alternative to building Kea from source.

The packages provide fast access to the latest bug fixes.

ISC provides the binary packages along with sources at the time of release.

### Kea binary packages from ISC

The open source packages contain the base Kea software and the following hooks libraries:
- Flexible Option
- Lease Commands
- High Availability
- Statistics Commands
- BOOTP

### Packages for support customers

Users of Kea that purchase professional Kea DHCP support from ISC are entitled to special software features that are not available in the open source version:
- Class Commands
- Configuration Backend Commands
- Flexible Identifier
- Forensic Logging
- Host Cache
- Host Commands
- RADIUS Support
- Subnet Commands

### The Kea hooks

The base Kea software implements the basic DHCPv4 and DHCPv6 functions.

These basic functions can be extended via hooks.
- The hooks are libraries that contain extra functions that will be called when a DHCP request is processed
- Hooks allow the core Kea system to stay lean
- Installations only load the functions used and needed
- This reduces the complexity and the attack surface of an installation

Types of hooks available:
- Hooks that are part of the Kea open source code (source and binary packages)
- Premium hooks that can be purchased online from the ISC website
- Hooks that are available for ISC support subscription customers
- Third party hooks (source code)

#### Premium / Subscription hooks

The premium / subscription hooks are available in source and binary (package) form
- Customers can download the hooks for a period of 12 month
- As the API between Kea and the hooks might change between Kea versions, care must be taken to install hooks that match the Kea version number.

### Kea Configuration

Configuration files for the DHCPv4, DHCPv6, DDNS, Control Agent, and NETCONF modules are defined in an extended JSON format.

#### Extended JSON

Kea components use an extended JSON with additional features:
- Shell comments: any text after the hash (#) character is ignored.
- C comments: any text after double slashes (//) is ignored.
- Multiline comments: any text between /* and */ is ignored. This commenting can span multiple lines.
- File inclusion: JSON files can include JSON files by using a statement of the form <?include "file.json"?>

### JSON Editor

When working with Kea, it helps to have an editor that understands the JSON format, can check the syntax and can highlight and reformat JSON data.
- Emacs
- Vim
- VSCode
- Textmate
- BBEdit

### Kea configuration files

The main Kea configuration files are:
- kea-ctrl-agent.conf - Kea control agent
- kea-dhcp-ddns.conf - Kea dynamic DNS updater
- kea-dhcp4.conf - Kea DHCPv4 server
- kea-dhcp6.conf - Kea DHCPv6 server
- keactrl.conf - configuration file for keactrl script (not in JSON format)

### A basic Kea DHCPv4 configuration

#### Network Interface and control socket

The Kea DHCP server needs to know on which network interfaces the DHCP service should listen on

The control socket defines the communication interface between the DHCP server process and the administration tools.

```bash
[...]
"Dhcp4": {
    // Add names of your network interfaces to listen on.
    "interfaces-config": {
        // interface name (e.g. "eth0" or specific IPv4 address on that
        // interface name (e.g. "eth0/192.0.2.1").
        "interfaces": [ "eth0" ]
    },
    "control-socket": {
        "socket-type": "unix",
        "socket-name": "/tmp/kea4-ctrl-socket"
    },
[...]
```

#### Lease database definition

Kea DHCP needs to know where to store the lease information.

The configuration snippet below defines an in-memory database.

```bash
[...]
    "lease-database": {
        // Memfile is the simplest and easiest backend to use. It's an in-memory
        // C++ database that stores its state in CSV file.
        "type": "memfile",
        "lfc-interval": 3600
    },
[...]
```

#### IPv4-Subnet and Pool definition

The example of a subnet below with DHCP pool definition includes subnet specific options (default router option: routers).

```bash
[...]
    "subnet4": [
        {
            "subnet": "192.0.2.0/24",
            "pools": [ { "pool": "192.0.2.1 - 192.0.2.200" } ],
            "option-data": [
                {
                    // For each IPv4 subnet you most likely need to specify at
                    // least one router.
                    "name": "routers",
                    "data": "192.0.2.1"
                }
            ],
[...]
```

#### Logging

Kea DHCP comes with a flexible and powerful logging framework.

The configuration snippet below configures a log-file for the DHCPv4 service.

```bash
[...]
    "loggers": [
    {
        "name": "kea-dhcp4",
        "output_options": [
            {
                // Specifies the output file. There are several special values
                // supported:
                // - stdout (prints on standard output)
                // - stderr (prints on standard error)
                // - syslog (logs to syslog)
                // - syslog:name (logs to syslog using specified name)
                // Any other value is considered a name of the file
                "output": "@localstatedir@/log/kea-dhcp4.log"
        "severity": "INFO",

        // If DEBUG level is specified, this value is used. 0 is least verbose,
        // 99 is most verbose. Be cautious, Kea can generate lots and lots
        // of logs if told to do so.
        "debuglevel": 0
[...]
```

### Checking the configuration for syntax errors

#### Kea configuration file check

After changes to a configuration file, and before reloading the new configuration into the Kea server, the configuration file should be checked for errors.

Syntax checks can be done with the -t (test) parameter.

```bash
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

### keactrl

keactrl is a shell script that can be used to control the Kea services
Care must be taken not to conflict with process supervision services such as systemd, runit or s6

keactrl can be used to start the Kea server modules

```bash
keactrl start
```

keactrl offers a status overview of the currently configured modules

```bash
keactrl status
```

After changing a Kea configuration file (and checking for errors), keactrl can be used to reload the configuration into the Kea processes

```bash
keactrl reload
```

On Linux systems, Kea comes with a set of systemd unit files that control the Kea services

```bash
systemctl start kea-dhcp4
```

Check the status of the Kea DHCPv4 service (Linux systemd)

```bash
systemctl status kea-dhcp4
```

### Testing DHCPv4 with the ISC DHCP client

Most Linux distributions provide the ISC DHCP client tool dhclient.
This tool can be used as a simple DHCP debugging tool.

dhclient as a debugging tool

Create a new shell script in ```/usr/local/sbin/dhclient-debug.sh``` with the lines below

```bash
#!/bin/sh
env
```

This script will pront all variables in its execution environment

Make the script executable.

```bash
sudo chmod +x /usr/local/sbin/dhclient-debug.sh
```

Execute the dhclient tool with this script

```bash
dhclient -sf /usr/local/sbin/dhclient-debug.sh
```

The script will print out all the information received from the DHCP server (via environment variables).

Can safely use the script. It will **NOT** reconfigure the client machines network stack!

### Performance benchmarking with perfdhcp

Kea comes with a DHCP benchmarking tool: perfdhcp.

This tool can be used to benchmark Kea, but also other DHCP server systems.

### Kea control agent

The Kea control agent is a process that provides a HTTP(s) REST interface.

The control agent can be used to dynamically reconfigure the Kea services (without manually changing the configuration files).

The Kea control agent communicates with the running Kea services via unix control sockets.

### Configuration of the Kea control agent

By default, the Kea control agent listens on the (first) IPv4 loopback address 172.0.0.1 Port 8000.

This can be changed in the configuration file ```kea-ctrl-agent.conf```

### Kea shell

The Kea Shell is a Python command line tool to interact with the Kea Control Agent REST API.

Kea shell example:

The Kea shell returns the JSON data from the Kea-Modules REST API.

Tools such as jq can be used to pretty print the output

```bash
kea-shell --service dhcp4 --host 127.0.0.1 --port 8000 version-get | jq
```

jq is not installed by default.

### Reading configuration data

The REST interface has been designed to be used from a Kea configuration application (such as Kea Stork or Kea Shell).

However, API calls can be sent to the Kea control agent from the command line via the curl tool.

Here we send the config-get command to the DHCPv4 server.

```bash
curl -X POST -H "Content-Type: application/json" \
    -d '{ "command": "config-get", "service": [ "dhcp4" ] }' \
    http://127.0.0.1:8000/
```

### Pretty printing the JSON output

The output is unformatted JSON. The tool jq can be used to pretty-print the output.

```bash
curl -X POST -H "Content-Type: application/json" \
    -d '{ "command": "config-get", "service": [ "dhcp4" ] }' \
    http://127.0.0.1:8000/ | jq
```

### JSON queries with jq

jq can be used to filter specific parts of the configuration.

The jq filter ".[0].arguments" can be used to produce a valid Kea configuration file.

The example below prints the logging config of the DHCPv4 server:

```bash
curl -X POST -H "Content-Type: application/json" \
    -d '{ "command": "config-get", "service": [ "dhcp4" ] }' \
    http://127.0.0.1:8000/ | jq ".[0].arguments.Dhcp4.loggers"
```

### List API commands

The list-commands command returns the API commands available for a specific Kea module

```bash
curl -X POST -H "Content-Type: application/json" \
    -d '{ "command": "list-commands", "service": [ "dhcp4" ] }' \
    http://127.0.0.1:8000/ | jq
```

### Dynamic changes to the Kea configuration file

With the REST API, it is possible to:

    Remotely fetch the current running config of a Kea server
    Change the config
    And write the config back to the server

1. Dump the current configuration into a file

```bash
curl -X POST -H "Content-Type: application/json" \
    -d '{ "command": "config-get", "service": [ "dhcp4" ] }' \
    http://127.0.0.1:8000/ | jq ".[0]" > kea-dhcp4.tmp
```

2. Edit the file

    Add the command and service information
    Make changes to the configuration
    Remove the 'result' from the JSON file

```bash
{
    "command": "config-set",
    "service": [ "dhcp4" ],
    "arguments": {
        "Logging": {
            "loggers": [
                {
                    "severity": "INFO",
                    "output_options": [
[...]
```

3. Send the new configuration to the server

```bash
curl -X POST -H "Content-Type: application/json" \
    -d @kea-dhcp4.tmp http://172.0.0.1:8000/ | jq
```

All dynamic changes are stored in memory.

To make the changes persistent, write the in-memory configuration back to a file\n
with the 'config-write' command (be carefule, any comments in the file will be gone and the formatting will be different).

```bash
curl -X POST -H "Content-Type: application/json" \
    -d '{ "command": "config-write", "arguments": { "filename": "/etc/kea/kea-dhcp4-new.conf" }, "service": [ "dhcp4" ] }' \
    http://127.0.0.1:8000/ | jq
```

### Kea DHCPv6 configuration

- The Kea DHCPv6 server is independent from the Kea DHCPv4 server
- Both can be started together on the same machine, or on separate machines
- The configuration file for the Kea DHCPv6 server is 'kea-dhcp6.conf'
- The Kea DHCPv6 server can be controlled from the 'keactrl' script or through systemd (on Linux)
- The DHCPv6 configuration can be managed through the Kea Control Agent and Kea Shell

### Kea DHCPv6 DUID

Each DHCPv6 server has a unique DHCP-Unique-ID (DUID).

When re-installing a DHCPv6 server, it might be useful to backup and restore the DUID of the system.

The Kea DHCPv6 DUID is stored in the file 'kea-dhcp6-serverid' in the '/var/lib/kea' directory (the path is system/distro dependent).

