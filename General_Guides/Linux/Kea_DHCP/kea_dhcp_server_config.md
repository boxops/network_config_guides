Kea DHCP Server Configuration
=============================

## Work in Progress...

### Notes

This configuration guide is focused on Debian Linux distributions, specifically the Ubuntu 22.04.1 LTS server distribution.

Kea uses JSON structures to represent server configurations. The following sections describe how the configuration structures are organized.

## JSON Syntax

Configuration files for the DHCPv4, DHCPv6, DDNS, Control Agent, and NETCONF modules are defined in an extended JSON format. Basic JSON is defined in RFC 7159 and ECMA 404. In particular, the only boolean values allowed are true or false (all lowercase). The capitalized versions (True or False) are not accepted.

Even though the JSON standard (ECMA 404) does not require JSON objects (i.e. name/value maps) to have unique entries, Kea implements them using a C++ STL map with unique entries. Therefore, if there are multiple values for the same name in an object/map, the last value overwrites previous values. **Since Kea 1.9.0, configuration file parsers raise a syntax error in such cases.**

### Extended JSON

Kea components use extended JSON with additional features allowed:
- Shell comments: any text after the hash (#) character is ignored.
- C comments: any text after the double slashes (//) character is ignored.
- Multiline comments: any text between /* and */ is ignored. This comment can span multiple lines.
- File inclusion: JSON files can include other JSON files by using a statement of the form \<?include "file.json"?\>.
- Extra commas: to remove the inconvenience of errors caused by leftover commas after making changes to configuration. While parsing, a warning is printed with the location of the comma to give the user the ability to correct a potential mistake.

**Warning: These features are meant to be used in a JSON configuration file. Their usage in any other way may result in errors.**

## Configuration File

The configuration file consists of a single object (often colloquially called a map) started with a curly bracket. It comprises only one of the "Dhcp4", "Dhcp6", "DhcpDdns", "Control-agent", or "Netconf" objects. It is possible to define additional elements but they will be ignored.

A very simple configuration for DHCPv4 could look like this:

```json
# The whole configuration starts here.
{
    # DHCPv4 specific configuration starts here.
    "Dhcp4": {
        "interfaces-config": {
            "interfaces": [ "eth0" ],
            "dhcp-socket-type": "raw"
        },
        "valid-lifetime": 4000,
        "renew-timer": 1000,
        "rebind-timer": 2000,
        "subnet4": [{
           "pools": [ { "pool": "192.0.2.1-192.0.2.200" } ],
           "subnet": "192.0.2.0/24"
        }],

       # Now loggers are inside the DHCPv4 object.
       "loggers": [{
            "name": "*",
            "severity": "DEBUG"
        }]
    }

# The whole configuration structure ends here.
}
```

More examples are available in the share/doc/kea/examples directory after installing the `isc-kea-doc` package.

### Comments as User Context

Shell, C, or C++ style comments are all permitted in the JSON configuration file if the file is used locally. This is convenient and works in simple cases where the configuration is kept statically using a local file. However, since comments are not part of JSON syntax, most JSON tools detect them as errors. Another problem with them is that once Kea loads its configuration, the shell, C, and C++ style comments are ignored. If commands such as config-get or config-write are used, those comments are lost. An example of such comments was presented in the previous section.

The concept of user context allows adding an arbitrary JSON structure to most Kea configuration structures.

This has a number of benefits compared to earlier approaches. First, it is fully compatible with JSON tools and Kea commands. Second, it allows storing simple comment strings, but it can also store much more complex data, such as multiple lines (as a string array), extra typed data (such as floor numbers being actual numbers), and more. Third, the data is exposed to hooks, so it is possible to develop third-party hooks that take advantage of that extra information. An example user context looks like this:

```json
"Dhcp4": {
    "subnet4": [{
        "subnet": "192.0.2.0/24",
        "pools": [{ "pool": "192.0.2.10 - 192.0.2.20" }],
        "user-context": {
            "comment": "second floor",
            "floor": 2
        }
    }]
}
```

User contexts can store an arbitrary data file as long as it has valid JSON syntax and its top-level element is a map (i.e. the data must be enclosed in curly brackets). However, some hook libraries may expect specific formatting.

Kea supports user contexts at the following levels: global scope, interfaces configuration, shared networks, subnets, client classes, option data and definitions, host reservations, control socket, DHCP-DDNS, loggers, leases, and server ID. These are supported in both DHCPv4 and DHCPv6, with the exception of server ID, which is DHCPv6 only.

User context can be added and edited in structures supported by commands.

For example, the subnet4-update command can be used to add user context data to an existing subnet.

```json
"subnet4": [ {
   "id": 1,
   "subnet": "10.20.30.0/24",
   "user-context": {
      "building": "Main"
      "floor": 1
      }
 } ]
 ```
 
 Kea also uses user context to store non-standard data. Currently, only Storing [Extended Lease Information](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcp4-store-extended-info) uses this feature.
 
 When enabled, it adds the ISC key in user-context to differentiate automatically added content.

Example of relay information stored in a lease:

```json
{
"arguments": {
   "client-id": "42:42:42:42:42:42:42:42",
   "cltt": 12345678,
   "fqdn-fwd": false,
   "fqdn-rev": true,
   "hostname": "myhost.example.com.",
   "hw-address": "08:08:08:08:08:08",
   "ip-address": "192.0.2.1",
   "state": 0,
   "subnet-id": 44,
   "valid-lft": 3600
   "user-context": {
      "ISC": {
      "relays": [
      {
            "hop": 2,
            "link": "2001:db8::1",
            "peer": "2001:db8::2"
      },
      {
            "hop": 1,
            "link": "2001:db8::3",
            "options": "0x00C800080102030405060708",
            "peer": "2001:db8::4"
      }]
      }
   }
}
```

User context can store configuration for multiple hooks and comments at once.

### Simplified Notation

It is sometimes convenient to refer to a specific element in the configuration hierarchy. Each hierarchy level is separated by a slash. If there is an array, a specific instance within that array is referenced by a number in square brackets (with numbering starting at zero). For example, in the above configuration the valid-lifetime in the Dhcp4 component can be referred to as Dhcp4/valid-lifetime, and the pool in the first subnet defined in the DHCPv4 configuration as `Dhcp4/subnet4[0]/pool`.

## Kea Configuration Backend

### Applicability

Kea Configuration Backend (CB or config backend) gives Kea servers the ability to manage and fetch their configuration from one or more databases. In this documentation, the term "Configuration Backend" may also refer to the particular Kea module providing support to manage and fetch the configuration information from the particular database type. For example, the MySQL Configuration Backend is the logic implemented within the mysql_cb hook library, which provides a complete set of functions to manage and fetch the configuration information from the MySQL database. The PostgreSQL Configuration Backend is the logic implemented within the pgsql_cb hook library, which provides a complete set of functions to manage and fetch the configuration information from the PostgreSQL database. From herein, the term "database" is used to refer to either a MySQL or PostgreSQL database.

In small deployments, e.g. those comprising a single DHCP server instance with limited and infrequently changing number of subnets, it may be impractical to use the CB as a configuration repository because it requires additional third-party software to be installed and configured - in particular the database server, client and libraries. Once the number of DHCP servers and/or the number of managed subnets in the network grows, the usefulness of the CB becomes obvious.

One use case for the CB is a pair of Kea DHCP servers that are configured to support High Availability as described in [ha: High Availability Outage Resilience for Kea Servers](https://kea.readthedocs.io/en/latest/arm/hooks.html#hooks-high-availability). The configurations of both servers (including the value of the `server-tag` parameter) are almost exactly the same: they may differ by the server identifier and designation of the server as a primary or standby (or secondary), and/or by their interfaces' configuration. Typically, the subnets, shared networks, option definitions, and global parameters are the same for both servers and can be sourced from a single database instance to both Kea servers.

Using the database as a single source of configuration for subnets and/or other configuration information supported by the CB has the advantage that any modifications to the configuration in the database are automatically applied to both servers.

Another case when the centralized configuration repository is useful is in deployments including a large number of DHCP servers, possibly using a common lease database to provide redundancy. New servers can be added to the pool frequently to fulfill growing scalability requirements. Adding a new server does not require replicating the entire configuration to the new server when a common database is used.

Using the database as a configuration repository for Kea servers also brings other benefits, such as:
- the ability to use database specific tools to access the configuration information;
- the ability to create customized statistics based on the information stored in the database; and
- the ability to backup the configuration information using the database's built-in replication mechanisms.

### Configuration Database Capabilities and Limitations

Currently, the Kea CB has the following limitations:
- It is only supported for MySQL and PostgreSQL databases.
- It is only supported for the DHCPv4 and DHCPv6 daemons; the Control Agent, D2 daemon, and the NETCONF daemon cannot be configured from the database,
- Only certain DHCP configuration parameters can be set in the database: global parameters, option definitions, global options, client classes, shared networks, and subnets. Other configuration parameters must be sourced from a JSON configuration file.

### Configuration Files Inclusion

The parser provides the ability to include files. The syntax was chosen to look similar to how Apache includes PHP scripts in HTML code. This particular syntax was chosen to emphasize that the include directive is an additional feature and not a part of JSON syntax.

The inclusion is implemented as a stack of files. You can use the include directive in nested includes. Up to ten nesting levels are supported. This arbitrarily chosen limit is protection against recursive inclusions.

The include directive has the form:

```bash
<?include "[PATH]"?>
```

The `[PATH]` pattern should be replaced with an absolute path or a path relative to the current working directory at the time the Kea process was launched.

To include one file from another, use the following syntax:

```bash
{
   "Dhcp6": {
      "interfaces-config": {
         "interfaces": [ "*" ]},
      "preferred-lifetime": 3000,
      "rebind-timer": 2000,
      "renew-timer": 1000,
      <?include "subnets.json"?>
      "valid-lifetime": 4000
   }
}
```

where the content of "subnets.json" may be:

```bash
"subnet4": [
   {
      "id": 123,
      "subnet": "192.0.2.0/24"
   },
   {
      "id": 234,
      "subnet": "192.0.3.0/24"
   },
   {
      "id": 345,
      "subnet": "10.0.0.0/8"
   }
],
```


## References
  - Kea Configuration: https://kea.readthedocs.io/en/latest/arm/config.html
