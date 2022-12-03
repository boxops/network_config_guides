# Assign a static private IP address to Raspberry Pi with DHCPCD

Raspbian Jessie, or Jessie Lite – the current Raspbian operating systems at the moment – have a DHCP client daemon (DHCPCD) that can communicate with the DHCP servers from routers. The configuration file of a DHCP client daemon allows you to change the private IP address of a computer and set it up in the long term. The following instructions will assign a static IPv4 address with 32 bits (not to be confused with an IPv6 address, which has 128 bits available) to the Raspberry Pi.

Before you begin with the assignment of a private IP address for Raspberry Pi, check whether DHCPCD is already activated using the following command:
```
sudo service dhcpcd status
```
In case it’s not, activate DHCPCD as follows:
```
sudo service dhcpcd start
```
```
sudo systemctl enable dhcpcd
```
Now make sure that the configuration of the file /etc/network/interfaceshas the original status. For this, the ‘iface’ configuration needs to be set at ‘manual’ for the interfaces.

For the editing of the activated DHCPCDs, start by opening the configuration file /etc/dhcpcd.confand running the following command:
```
sudo nano /etc/dhcpcd.conf
```
You’ll now carry out the configuration of the static IP address. If your Raspberry Pi is connected to the internet via an Ethernet or network cable, then enter the command ‘interface eth0’; if it takes place over Wi-Fi, then use the ‘interface wlan’ command.

To assign an IP address to Raspberry Pi, use the command ‘static ip_address=’ followed by the desired IPv4 address and the suffix ‘/24’ (an abbreviation of the subnet mak 255.255.255.0). For example, if you want to link a computer with the IPv4 address 192.168.0.4, then you need to use the command ‘static ip_address=192.168.0.4/24’. It goes without saying that the address used here is not yet used anywhere else. As such, it also can’t be located in the address pool of a DHCP server.

You still then need to specify the address of your gateway and domain name server (usually both are the router). Raspberry Pi turns to the gateway address if an IP address to which it wants to send something is outside of the subnet mask (in the example, this would mean outside of the range 192.168.0). In the following command, the IPv4 address 192.168.0.1 is used as an example as both the gateway and DNS server. The complete command looks like this in our example (where a network cable is used for the internet connection):
```
interface eth0
static ip_address=192.168.0.4/24
static routers=192.168.0.1
static domain_name_servers=192.168.0.1
```
The command lines above match the IPv4 addresses that you want to use for your Raspberry Pi, or where your router is assigned. Save the changes with ‘Ctrl + O’ and then press the enter key. Close the configuration file with ‘Ctrl + X’. Restart to adopt the newly assigned static IP address in the network:
```
sudo reboot
```
Now use a ping command to check whether the Raspberry Pi is accessible in the network with its new IP address:
```
ping raspberrypi.local
```
If the connection of the IP address was successful, you’ll see that you can reach it under the new IP address with a ping.
