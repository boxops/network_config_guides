10 basic Linux networking commands you should know about
========================================================

### 1. ip

Show details of the network interfaces:

```bash
ip a
```

Show details of the routing table:

```bash
ip r
```

Show details of a specific network interface:

```bash
ip a show enp0s3
```

Monitor all IP traffic (useful when troubleshooting):

```bash
ip monitor all
```

### 2. arp

Show the IP address with a matching hardware address

```bash
arp -a
```

Show details of a specific network interface:

```bash
arp -e -i enp0s3
```

Note: The ARP table for an interface is updated once traffic starts flowing through that interface.\
The hardware address will not show up otherwise.

### 3. ping

Test if a remote machine is reachable:

```bash
ping kernel.org
```

Set the number of pings:

```bash
ping -c 5 kernel.org
```

Ping with a set interval:

```bash
ping -i 0.2 -c 10 kernel.org
```

### 4. ss

Show open TCP ports listening on a machine:

```bash
ss -ltn
```

Show open UDP ports listening on a machine:

```bash
ss -lun
```

### 5. nmap

Test the port availability of a remote machine:

```bash
nmap -v kernel.org
```

Scan an entire subnet:

```bash
nmap -v 192.168.50.0/24
```

### 6. dig

Resolve hostnames and get IP addresses of a domain:

```bash
dig kernel.org
```

Reverse lookup the IP address to get a domain name:

```bash
dig -x 139.178.84.217
```

### 7. traceroute

Show routing hops from the localhost to a remote machine (using UDP by default):

```bash
traceroute kernel.org
```

Note: star output means that some UDP ports are blocked

Use the ICMP TCP protocol instead of UDP:

```bash
traceroute -I kernel.org
```

### 8. mtr

Show dynamic routing information from localhost to a remote machine (advanced traceroute tool):

```bash
mtr kernel.org
```

Show IP addresses instead of hosnames of hops:

```bash
mtr -n kernel.org
```

### 9. tcpdump

Monitor live network traffic:

```bash
tcpdump -vv -i enp0s3 port 80
```

### 10. termshark

Monitor live network traffic using tshark (similar to tcpdump but has filtering options):

```bash
termshark -i enp0s3
```
