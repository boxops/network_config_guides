ISC DHCP Server Deployment Guide
================================

### Note: Some parts of this guide also applies to the KEA DHCP Server.

### Install Packages

```bash
sudo apt install isc-dhcp-server -y
```

### Open the **dhcpd.conf** file and edit the contents

```bash
sudo nano /etc/dhcp/dhcpd.conf
```

1. Activate the server by uncommenting the **authoritative** line.
2. Add one or more subnet configuration block to the file.
3. Save the file.

### Restart the ISC DHCP server and check its status

```bash
sudo systemctl restart isc-dhcp-server && sudo systemctl status isc-dhcp-server
```

### Add the standard DHCP port 67 firewall rule that allows inbound DHCP traffic to the server

### Notes: 

- Ensure to enable the UFW service before adding rules
- Enabling the UFW service could disable all other ports such as SSH port 22 due to the explicit denial.

```bash
sudo ufw enable
```

```bash
sudo ufw allow 67
```

### Check the status of the added firewall rule:

```bash
sudo ufw status
```

### Call tcpdump with verbose output 

```bash
sudo tcpdump -vv -n -i enp0s3 port 67
```

### Options explanation:

-vv -> Verbose\
-n -> Numbering\
-i -> Interface

### Watch the DHCP lease list after clients are given IP leases

```bash
sudo watch dhcp-lease-list
```

### Another way of checking DHCP leases

```bash
sudo cat /var/lib/dhcp/dhcpd.leases
```

### On DHCP Clients, request or release an IP from the DHCP server

### Request:

```bash
sudo dhclient
```

### Release:

```bash
sudo dhclient -r
```

Troubleshoot DHCP communication problems
========================================

DHCP uses a four-step process to enable clients to lease an IP address configuration:

    DHCP DISCOVER: Client broadcasts that it needs to lease an IP configuration from a DHCP server
    DHCP OFFER: Server broadcasts to offer an IP configuration
    DHCP REQUEST: Client broadcasts to formally ask for the offered IP configuration
    DHCP ACKNOWLEDGE (ACK): Server broadcasts confirming the leased IP configuration

These broadcasts use ports 67/udp and 68/udp.

### 1. Start with the basics

First, check all the basics:

    Does physical connectivity exist with functional network media?
    Have you restarted the DHCP service?
    Is a DHCP scope configured?
    Do the server and client logs display any clues as to why the leases fail? (If so, try to fix those issues before moving on.)

### 2. Scan for the DHCP server

One logical step is to confirm that the DHCP service device has a network presence.\
Begin with a basic ping sweep that identifies all hosts on the segment.\
Run the scan from a connected device with a static IP address configuration.

```bash
sudo nmap -sn 192.168.1.1-255
```

### 3. Sniffing network traffic with tcpdump

Install tcpdump:

```bash
sudo apt install tcpdump -y
```

The network interface you want to monitor must be in promiscuous mode.\
You set this using the ip command. For example, to configure eth0:

```bash
sudo ip link set eth0 promisc on
```

You can configure tcpdump to grab specific network packet types, and on a busy network,\
it's a good idea to focus on just the protocol needed. This example gathers information\
on eth0 for UDP ports 67 and 68 (DHCP) in verbose mode. tcpdump writes the output to a file named dhcp.pcap:

```bash
tcpdump -i eth0 udp port 67 and port 68 -vv -w dhcp.pcap
```

View the file's contents using tcpdump (rather than a standard text editor!).\
The read option is -r, followed by the filename:

```bash
tcpdump -r dhcp.pcap
```

### 4. Sniffing network traffic with Wireshark

tcpdump can read the file, but it may be more visually appealing and easier to filter the output by opening\
the file in Wireshark. Launch Wireshark, go to the File menu, select Open, and select the output .pcap file.

First, establish whether the clients sent DHCP DISCOVER queries (remember, the client initiates the lease-generation process).\
If so, then the clients are likely functioning properly. If DHCP DISCOVER queries are getting sent,\
check for DHCP OFFER responses from the server. Do these responses exist and are they offering the correct information?

### 5. Use an Nmap script

While Nmap can conduct general scans and protocol analyzers can display information based on packet captures,\
what about a more complete solution? Browse the Nmap site for the Nmap Scripting Engine (NSE). (URL: https://nmap.org/nsedoc/)\
It contains more than 600 scripts with preconfigured settings for various Nmap scans. Authors create and share these scripts.\
In this scenario, the broadcast-dhcp-discover script helps with DHCP troubleshooting.

The script generates a DHCP DISCOVER message, the same as a standard DHCP client, and logs the DHCP OFFER responses from any DHCP servers.\
The basic syntax for Nmap scripts, with the DHCP broadcast script as an example, is nmap --script broadcast-dhcp-discover.

```bash
nmap -sU -p67 --script broadcast-dhcp-discover
```

The unicast version of the script, dhcp-discover, sends a direct query to the DHCP server. Notice the query is addressed to the DHCP server:

```bash
nmap -sU -p67 --script dhcp-discover 10.10.10.1$ 
```

This query generates a response from the server that provides basic configuration information and suggests that the service is communicating.\
The response to this message may vary by DHCP service type, but any response should indicate functionality.\
The DHCP server is likely misconfigured, not running, blocked, or otherwise unavailable if no response is detected.\
Regardless, it identifies the server as the problem in this scenario.

Note: There are corresponding scripts for IPv6 network troubleshooting, as well.
