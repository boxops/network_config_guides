# List of Kea Tools with Examples


## `kea-dhcp4` - [DHCPv4 server in Kea](https://kea.readthedocs.io/en/kea-2.2.0/man/kea-dhcp4.8.html)

### Command options:

```
Kea DHCPv4 server, version 2.2.0 (stable)

Usage: kea-dhcp4 -[v|V|W] [-d] [-{c|t} cfgfile] [-p number] [-P number]
  -v: print version number and exit
  -V: print extended version and exit
  -W: display the configuration report and exit
  -d: debug mode with extra verbosity (former -v)
  -c file: specify configuration file
  -t file: check the configuration file syntax and exit
  -p number: specify non-standard server port number 1-65535 (useful for testing only)
  -P number: specify non-standard client port number 1-65535 (useful for testing only)
```

### Examples

### Check the config file syntax:

```
kea-dhcp4 -t /etc/kea/kea-dhcp4.conf
```

## `kea-dhcp6` - [DHCPv6 server in Kea](https://kea.readthedocs.io/en/kea-2.2.0/man/kea-dhcp6.8.html)

### Command options:

```
Kea DHCPv6 server, version 2.2.0 (stable)

Usage: kea-dhcp6 -[v|V|W] [-d] [-{c|t} cfgfile] [-p number] [-P number]
  -v: print version number and exit
  -V: print extended version and exit
  -W: display the configuration report and exit
  -d: debug mode with extra verbosity (former -v)
  -c file: specify configuration file
  -t file: check the configuration file syntax and exit
  -p number: specify non-standard server port number 1-65535 (useful for testing only)
  -P number: specify non-standard client port number 1-65535 (useful for testing only)
```

### Examples

### Check the config file syntax:

```
kea-dhcp6 -t /etc/kea/kea-dhcp6.conf
```


## `kea-ctrl-agent` - [Control Agent process in Kea](https://kea.readthedocs.io/en/kea-2.2.0/man/kea-ctrl-agent.8.html)

### Command options:

```
Usage: kea-ctrl-agent
  -v: print version number and exit
  -V: print extended version information and exit
  -W: display the configuration report and exit
  -d: optional, verbose output 
  -c <config file name> : mandatory, specify name of configuration file
  -t <config file name> : check the configuration file and exit
```

### Examples

### Check the config file syntax:

```
kea-ctrl-agent -t /etc/kea/kea-ctrl-agent.conf
```

## `keactrl` - [Shell script for managing Kea](https://kea.readthedocs.io/en/kea-2.2.0/man/keactrl.8.html)

### Command options:

### Examples

## `kea-admin` - [Shell script for managing Kea databases](https://kea.readthedocs.io/en/kea-2.2.0/man/kea-admin.8.html)

### Command options:

```
kea-admin 2.2.0

This is a kea-admin script that conducts administrative tasks on
the Kea installation.

Usage: /usr/sbin/kea-admin COMMAND BACKEND [parameters]

COMMAND: Currently supported operations are:

 - db-init: Initializes new database. Useful for first time installation.
 - db-version: Checks version of the existing database schema. Useful
 -             for checking database version when preparing for an upgrade.
 - db-upgrade: Upgrades your database schema.
 - lease-dump: Dumps current leases to a memfile-ready CSV file.
 - lease-upload: Uploads leases from a CSV file to the database.
 - stats-recount: Recounts lease statistics.

BACKEND - one of the supported backends: memfile|mysql|pgsql

PARAMETERS: Parameters are optional in general, but may be required
            for specific operations.
 -h or --host hostname - specifies a hostname of a database to connect to
 -P or --port port - specifies the TCP port to use for the database connection
 -u or --user name - specifies username when connecting to a database
 -p or --password [password] - specifies a password for the database connection;
                               if omitted from the command line,
                               then the user will be prompted for a password
 -n or --name database - specifies a database name to connect to
 -d or --directory - path to upgrade scripts (default: /usr/share/kea/scripts)
 -v or --version - print kea-admin version and quit.
 -x or --extra - specifies extra argument(s) to pass to the database command

 Parameters specific to lease-dump, lease-upload:
     -4 to dump IPv4 leases to file
     -6 to dump IPv6 leases to file
     -i or --input to specify the name of file from which leases will be uploaded
     -o or --output to specify the name of file to which leases will be dumped
     -y or --yes - assume yes on overwriting temporary files
```

### Examples

### Dump the leases into a text file from a database

```
sudo kea-admin lease-dump pgsql -h localhost -P 5432 -u admin -p supersecretdatabasepassword -n dhcp -4 -o /var/lib/kea/kea-leases4-dump.txt
```

## `kea-dhcp-ddns` - [DHCP-DDNS process in Kea](https://kea.readthedocs.io/en/kea-2.2.0/man/kea-dhcp-ddns.8.html)

### Command options:

```
Usage: kea-dhcp-ddns
  -v: print version number and exit
  -V: print extended version information and exit
  -W: display the configuration report and exit
  -d: optional, verbose output 
  -c <config file name> : mandatory, specify name of configuration file
  -t <config file name> : check the configuration file and exit
```

### Examples

## `kea-lfc` - [Lease File Cleanup process in Kea](https://kea.readthedocs.io/en/kea-2.2.0/man/kea-lfc.8.html)

### Command options:

```
Usage: kea-lfc
 [-4|-6] -p file -x file -i file -o file -f file -c file
   -4 or -6 clean a set of v4 or v6 lease files
   -p <file>: PID file
   -x <file>: previous or ex lease file
   -i <file>: copy of lease file
   -o <file>: output lease file
   -f <file>: finish file
   -c <file>: configuration file
   -v: print version number and exit
   -V: print extended version information and exit
   -d: optional, verbose output 
   -h: print this message 
```

### Examples

## `kea-shell` - [Text client for Control Agent process](https://kea.readthedocs.io/en/kea-2.2.0/man/kea-shell.8.html)

### Command options:

```
usage: kea-shell [-h] [--host HOST] [--port PORT] [--path PATH] [--ca CA] [--cert CERT] [--key KEY] [--timeout TIMEOUT] [--service [SERVICE]] [--auth-user AUTH_USER]
                 [--auth-password AUTH_PASSWORD] [-v]
                 [command]

kea-shell is a simple text client that uses REST interface to connect to Kea Control Agent.

positional arguments:
  command               command to be executed. If not specified, "list-commands" is used

options:
  -h, --help            show this help message and exit
  --host HOST           hostname of the CA to connect to (default:; 127.0.0.1)
  --port PORT           TCP port of the CA to connect to (default: 8000)
  --path PATH           Path of the URL to connect to (default: "")
  --ca CA               File or directory name of the CA (default: "" i.e. do not use HTTPS)
  --cert CERT           File name of the client certificate (default: "")
  --key KEY             File name of the client private key (default: "")
  --timeout TIMEOUT     Timeout (in seconds) when attempting to connect to CA (default: 10)
  --service [SERVICE]   target specified service. If not specified,control agent will receive command.
  --auth-user AUTH_USER
                        Basic HTTP authentication user
  --auth-password AUTH_PASSWORD
                        Basic HTTP authentication password
  -v                    Prints version
```

### Examples

### Return the JSON data from the Kea-Modules REST API:

```
sudo kea-shell --service dhcp4 --host 192.168.30.32 --port 8000 version-get | jq
```

### API calls can be sent to the Kea control agent from the command line via the `curl` tool:

```
curl -X POST -H "Content-Type: application/json" -d '{ "command": "config-get", "service": [ "dhcp4" ] }' http://192.168.30.32:8000 | jq
```

### `jq` can be used to filter specific parts of the configuration:

```
curl -X POST -H "Content-Type: application/json" -d '{ "command": "config-get", "service": [ "dhcp4" ] }' http://192.168.30.32:8000 | jq ".[0].arguments.Dhcp4.loggers"
```

### The `list-commands` command returns the API commands available for a specific Kea module:

```
curl -X POST -H "Content-Type: application/json" -d '{ "command": "list-commands", "service": [ "dhcp4" ] }' http://192.168.30.32:8000 | jq
```

### Apply dynamic changes to the configuration file

#### 1. Dump the current configuration into a file:

```
curl -X POST -H "Content-Type: application/json" -d '{ "command": "config-get", "service": [ "dhcp4" ] }' http://192.168.30.32:8000 | jq ".[0]" > /tmp/kea-dhcp4.tmp
```

#### 2. Edit the config file:

- Add the `command` and `service` information
- Make changes to the configuration
- Remove the `result` from the JSON file

```
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

#### 3. Send the new configuration to the server

```
curl -s -X POST -H "Content-Type: application/json" -d @kea-dhcp4.tmp http://192.168.30.32:8000 | jq
```

#### 4. To make the changes persistent, write the in-memory configuration back to a file with the `config-write` command (any comments in the file will be gone):

```
curl -X POST -H "Content-Type: application/json" -d '{ "command": "config-write", "arguments": "/etc/kea/kea-dhcp4-new.json" }' http://192.168.30.32:8000 | jq
```


## `kea-netconf` - [NETCONF agent for configuring Kea](https://kea.readthedocs.io/en/kea-2.2.0/man/kea-netconf.8.html)

### Command options:

```
Usage: kea-netconf
  -v: print version number and exit
  -V: print extended version information and exit
  -W: display the configuration report and exit
  -d: optional, verbose output 
  -c <config file name> : mandatory, specify name of configuration file
  -t <config file name> : check the configuration file and exit
```

### Examples

## `perfdhcp` - [DHCP benchmarking tool](https://kea.readthedocs.io/en/kea-2.2.0/man/perfdhcp.8.html)

### Command options:

```
perfdhcp [-1] [-4 | -6] [-A encapsulation-level] [-b base] [-B] [-c]
         [-C separator] [-d drop-time] [-D max-drop] [-e lease-type]
         [-E time-offset] [-f renew-rate] [-F release-rate] [-g thread-mode]
         [-h] [-i] [-I ip-offset] [-J remote-address-list-file]
         [-l local-address|interface] [-L local-port] [-M mac-list-file]
         [-n num-request] [-N remote-port] [-O random-offset]
         [-o code,hexstring] [-p test-period] [-P preload] [-r rate]
         [-R num-clients] [-s seed] [-S srvid-offset] [--scenario name]
         [-t report] [-T template-file] [-u] [-v] [-W exit-wait-time]
         [-w script_name] [-x diagnostic-selector] [-X xid-offset] [server]
```

### Examples

### Test a DHCP server by sending 100 requests

```
sudo perfdhcp -xi -t 2 -r 10 -R 100 192.168.30.29
```

## References:
- [Manual Pages](https://kea.readthedocs.io/en/kea-2.2.0/manpages.html)
