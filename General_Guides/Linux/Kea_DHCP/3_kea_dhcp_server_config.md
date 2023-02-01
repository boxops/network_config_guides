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

## The DHCPv4 Server

### Starting and Stopping the DHCPv4 Server

The Kea DHCPv4 server be started and stopped using the `kea-dhcp4` command, which accepts the following command-line switches:

- -c file - specifies the configuration file. This is the only mandatory switch.
- -d - specifies whether the server logging should be switched to debug/verbose mode. In verbose mode, the logging severity and debuglevel specified in the configuration file are ignored; "debug" severity and the maximum debuglevel (99) are assumed. The flag is convenient for temporarily switching the server into maximum verbosity, e.g. when debugging.
- -p server-port - specifies the local UDP port on which the server listens. This is only useful during testing, as a DHCPv4 server listening on ports other than the standard ones is not able to handle regular DHCPv4 queries.
- -P client-port - specifies the remote UDP port to which the server sends all responses. This is only useful during testing, as a DHCPv4 server sending responses to ports other than the standard ones is not able to handle regular DHCPv4 queries.
- -t file - specifies a configuration file to be tested. kea-dhcp4 loads it, checks it, and exits. During the test, log messages are printed to standard output and error messages to standard error. The result of the test is reported through the exit code (0 = configuration looks OK, 1 = error encountered). The check is not comprehensive; certain checks are possible only when running the server.
- -v - displays the Kea version and exits.
- -V - displays the Kea extended version with additional parameters and exits. The listing includes the versions of the libraries dynamically linked to Kea.
- -W - displays the Kea configuration report and exits. The report is a copy of the config.report file produced by ./configure; it is embedded in the executable binary.

On startup, the server detects available network interfaces and attempts to open UDP sockets on all interfaces listed in the configuration file. Since the DHCPv4 server opens privileged ports, it requires root access; this daemon must be run as root.

During startup, the server attempts to create a PID file of the form: `[runstatedir]/kea/[conf name].kea-dhcp4.pid`, where:

- `runstatedir`: The value as passed into the build configure script; it defaults to `/usr/local/var/run`. Note that this value may be overridden at runtime by setting the environment variable KEA_PIDFILE_DIR, although this is intended primarily for testing purposes.

- `conf name`: The configuration file name used to start the server, minus all preceding paths and the file extension. For example, given a pathname of `/usr/local/etc/kea/myconf.txt`, the portion used would be `myconf`.

If the file already exists and contains the PID of a live process, the server issues a `DHCP4_ALREADY_RUNNING` log message and exits. It is possible, though unlikely, that the file is a remnant of a system crash and the process to which the PID belongs is unrelated to Kea. In such a case, it would be necessary to manually delete the PID file.

The server can be stopped using the `kill` command. When running in a console, the server can also be shut down by pressing Ctrl-c. Kea detects the key combination and shuts down gracefully.

### DHCPv4 Server Configuration

This section explains how to configure the Kea DHCPv4 server using a configuration file.

Before DHCPv4 is started, its configuration file must be created. The basic configuration is as follows:

```json
{
# DHCPv4 configuration starts on the next line
"Dhcp4": {

# First we set up global values
    "renew-timer": 1000,
    "rebind-timer": 2000,
    "valid-lifetime": 4000,

# Next we set up the interfaces to be used by the server.
    "interfaces-config": {
        "interfaces": [ "eth0" ]
    },

# And we specify the type of lease database
    "lease-database": {
        "type": "memfile",
        "persist": true,
        "name": "/var/lib/kea/dhcp4.leases"
    },

# Finally, we list the subnets from which we will be leasing addresses.
    "subnet4": [
        {
            "subnet": "192.0.2.0/24",
            "pools": [
                {
                    "pool": "192.0.2.1 - 192.0.2.200"
                }
            ]
        }
    ]
# DHCPv4 configuration ends with the next line
}

}
```

The following paragraphs provide a brief overview of the parameters in the above example, along with their format. Subsequent sections of this chapter go into much greater detail for these and other parameters.

The lines starting with a hash (#) are comments and are ignored by the server; they do not impact its operation in any way.

The configuration starts in the first line with the initial opening curly bracket (or brace). Each configuration must contain an object specifying the configuration of the Kea module using it. In the example above, this object is called `Dhcp4`.

The Dhcp4 configuration starts with the `"Dhcp4": {` line and ends with the corresponding closing brace (in the above example, the brace after the last comment). Everything defined between those lines is considered to be the `Dhcp4` configuration.

In general, the order in which those parameters appear does not matter, but there are two caveats. The first one is that the configuration file must be well-formed JSON, meaning that the parameters for any given scope must be separated by a comma, and there must not be a comma after the last parameter. When reordering a configuration file, moving a parameter to or from the last position in a given scope may also require moving the comma. The second caveat is that it is uncommon — although legal JSON — to repeat the same parameter multiple times. If that happens, the last occurrence of a given parameter in a given scope is used, while all previous instances are ignored. This is unlikely to cause any confusion as there are no real-life reasons to keep multiple copies of the same parameter in the configuration file.

The first few DHCPv4 configuration elements define some global parameters. `valid-lifetime` defines how long the addresses (leases) given out by the server are valid; the default is for a client to be allowed to use a given address for 4000 seconds. (Note that integer numbers are specified as is, without any quotes around them.) `renew-timer` and `rebind-timer` are values (also in seconds) that define the T1 and T2 timers that govern when the client begins the renewal and rebind processes.

#### Notes

The lease valid lifetime is expressed as a triplet with minimum, default, and maximum values using configuration entries `min-valid-lifetime`, `valid-lifetime`, and `max-valid-lifetime`. Since Kea 1.9.5, these values may be specified in client classes. The procedure the server uses to select which lifetime value to use is as follows:

If the client query is a BOOTP query, the server always uses the infinite lease time (e.g. 0xffffffff). Otherwise, the server must determine which configured triplet to use by first searching all classes assigned to the query, and then the subnet selected for the query.

Classes are searched in the order they were assigned to the query; the server uses the triplet from the first class that specifies it. If no classes specify the triplet, the server uses the triplet specified by the subnet selected for the client. If the subnet does not explicitly specify it, the server next looks at the subnet's shared-network (if one exists), then for a global specification, and finally the global default.

If the client requested a lifetime value via DHCP option 51, then the lifetime value used is the requested value bounded by the configured triplet. In other words, if the requested lifetime is less than the configured minimum, the configured minimum is used; if it is more than the configured maximum, the configured maximum is used. If the client did not provide a requested value, the lifetime value used is the triplet default value.

Both `renew-timer` and `rebind-timer` are optional. The server only sends rebind-timer to the client, via DHCPv4 option code 59, if it is less than `valid-lifetime`; and it only sends `renew-timer`, via DHCPv4 option code 58, if it is less than `rebind-timer` (or `valid-lifetime` if rebind-timer was not specified). In their absence, the client should select values for T1 and T2 timers according to [RFC 2131](https://tools.ietf.org/html/rfc2131). See section [Sending T1 (Option 58) and T2 (Option 59)](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcp4-t1-t2-times) for more details on generating T1 and T2.

#### Interface config

The `interfaces-config` map specifies the network interfaces on which the server should listen to DHCP messages. The `interfaces` parameter specifies a list of network interfaces on which the server should listen. Lists are opened and closed with square brackets, with elements separated by commas. To listen on two interfaces, the `interfaces-config` element should look like this:

```json
"interfaces-config": {
    "interfaces": [ "eth0", "eth1" ]
},
```

The next lines define the lease database, the place where the server stores its lease information. This particular example tells the server to use memfile, which is the simplest and fastest database backend. It uses an in-memory database and stores leases on disk in a CSV (comma-separated values) file. This is a very simple configuration example; usually the lease database configuration is more extensive and contains additional parameters. Note that `lease-database` is an object and opens up a new scope, using an opening brace. Its parameters (just one in this example: `type`) follow. If there were more than one, they would be separated by commas. This scope is closed with a closing brace. As more parameters for the Dhcp4 definition follow, a trailing comma is present.

```json
"lease-database": {
    "type": "memfile",
    "persist": true,
    "name": "/var/lib/kea/dhcp4.leases"
},
```

Finally, we need to define a list of IPv4 subnets. This is the most important DHCPv4 configuration structure, as the server uses that information to process clients' requests. It defines all subnets from which the server is expected to receive DHCP requests. The subnets are specified with the `subnet4` parameter. It is a list, so it starts and ends with square brackets. Each subnet definition in the list has several attributes associated with it, so it is a structure and is opened and closed with braces. At a minimum, a subnet definition must have at least two parameters: `subnet`, which defines the whole subnet; and `pools`, which is a list of dynamically allocated pools that are governed by the DHCP server.

The example contains a single subnet. If more than one were defined, additional elements in the `subnet4` parameter would be specified and separated by commas. For example, to define three subnets, the following syntax would be used:

```json
"subnet4": [
    {
        "pools": [ { "pool":  "192.0.2.1 - 192.0.2.200" } ],
        "subnet": "192.0.2.0/24"
    },
    {
        "pools": [ { "pool": "192.0.3.100 - 192.0.3.200" } ],
        "subnet": "192.0.3.0/24"
    },
    {
        "pools": [ { "pool": "192.0.4.1 - 192.0.4.254" } ],
        "subnet": "192.0.4.0/24"
    }
]
```

Note that indentation is optional and is used for aesthetic purposes only. In some cases it may be preferable to use more compact notation.

After all the parameters have been specified, there are two contexts open: global and Dhcp4; thus, two closing curly brackets must be used to close them.

## Lease Storage

All leases issued by the server are stored in the lease database. There are three database backends available: memfile (the default), MySQL, PostgreSQL.

### Memfile - Basic Storage for Leases

The server is able to store lease data in different repositories. Larger deployments may elect to store leases in a database; [Lease Database Configuration](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#database-configuration4) describes this option. In typical smaller deployments, though, the server stores lease information in a CSV file rather than a database. As well as requiring less administration, an advantage of using a file for storage is that it eliminates a dependency on third-party database software.

An example configuration of the memfile backend is presented below:

```json
"Dhcp4": {
    "lease-database": {
        "type": "memfile",
        "persist": true,
        "name": "/tmp/kea-leases4.csv",
        "lfc-interval": 1800,
        "max-row-errors": 100
    }
}
```

This configuration selects `/tmp/kea-leases4.csv` as the storage for lease information and enables persistence (writing lease updates to this file). It also configures the backend to perform a periodic cleanup of the lease file every 1800 seconds (30 minutes) and sets the maximum number of row errors to 100.

The configuration of the memfile backend is controlled through the `Dhcp4`/`lease-database` parameters. The `type` parameter is mandatory and specifies which storage for leases the server should use, through the `"memfile"` value. The following list gives additional optional parameters that can be used to configure the memfile backend.

- `persist`: controls whether the new leases and updates to existing leases are written to the file. It is strongly recommended that the value of this parameter be set to `true` at all times during the server's normal operation. Not writing leases to disk means that if a server is restarted (e.g. after a power failure), it will not know which addresses have been assigned. As a result, it may assign new clients addresses that are already in use. The value of `false` is mostly useful for performance-testing purposes. The default value of the `persist` parameter is `true`, which enables writing lease updates to the lease file.
- `name`: specifies an absolute location of the lease file in which new leases and lease updates are recorded. The default value for this parameter is `"[kea-install-dir]/var/lib/kea/kea-leases4.csv"`.
- `lfc-interval`: specifies the interval, in seconds, at which the server will perform a lease file cleanup (LFC). This removes redundant (historical) information from the lease file and effectively reduces the lease file size. The cleanup process is described in more detail later in this section. The default value of the `lfc-interval` is `3600`. A value of `0` disables the LFC.
- `max-row-errors`: specifies the number of row errors before the server stops attempting to load a lease file. When the server loads a lease file, it is processed row by row, each row containing a single lease. If a row is flawed and cannot be processed correctly the server logs it, discards the row, and goes on to the next row. This parameter can be used to set a limit on the number of such discards that can occur, after which the server abandons the effort and exits. The default value of `0` disables the limit and allows the server to process the entire file, regardless of how many rows are discarded.

#### Why Is Lease File Cleanup Necessary?

It is important to know how the lease file contents are organized to understand why the periodic lease file cleanup is needed. Every time the server updates a lease or creates a new lease for a client, the new lease information must be recorded in the lease file. For performance reasons, the server does not update the existing client's lease in the file, as this would potentially require rewriting the entire file. Instead, it simply appends the new lease information to the end of the file; the previous lease entries for the client are not removed. When the server loads leases from the lease file, e.g. at server startup, it assumes that the latest lease entry for the client is the valid one. Previous entries are discarded, meaning that the server can reconstruct accurate information about the leases even though there may be many lease entries for each client. However, storing many entries for each client results in a bloated lease file and impairs the performance of the server's startup and reconfiguration, as it needs to process a larger number of lease entries.

Lease file cleanup (LFC) removes all previous entries for each client and leaves only the latest ones. The interval at which the cleanup is performed is configurable, and it should be selected according to the frequency of lease renewals initiated by the clients. The more frequent the renewals, the smaller the value of `lfc-interval` should be. Note, however, that the LFC takes time and thus it is possible (although unlikely) that, if the `lfc-interval` is too short, a new cleanup may be started while the previous one is still running. The server would recover from this by skipping the new cleanup when it detected that the previous cleanup was still in progress, but it implies that the actual cleanups will be triggered more rarely than the configured interval. Moreover, triggering a new cleanup adds overhead to the server, which is not able to respond to new requests for a short period of time when the new cleanup process is spawned. Therefore, it is recommended that the `lfc-interval` value be selected in a way that allows the LFC to complete the cleanup before a new cleanup is triggered.

Lease file cleanup is performed by a separate process (in the background) to avoid a performance impact on the server process. To avoid conflicts between two processes using the same lease files, the LFC process starts with Kea opening a new lease file; the actual LFC process operates on the lease file that is no longer used by the server. There are also other files created as a side effect of the lease file cleanup. The detailed description of the LFC process is located later in this Kea Administrator's Reference Manual: [The LFC Process](https://kea.readthedocs.io/en/latest/arm/lfc.html#kea-lfc).

### Lease Database Configuration

Lease database access information must be configured for the DHCPv4 server, even if it has already been configured for the DHCPv6 server. The servers store their information independently, so each server can use a separate database or both servers can use the same database.

Kea requires the database timezone to match the system timezone. For more details, see [First-Time Creation of the MySQL Database](https://kea.readthedocs.io/en/latest/arm/admin.html#mysql-database-create) and [First-Time Creation of the PostgreSQL Database](https://kea.readthedocs.io/en/latest/arm/admin.html#pgsql-database-create).

Lease database configuration is controlled through the `Dhcp4`/`lease-database` parameters. The database type must be set to `memfile`, `mysql` or `postgresql`, e.g.:

```json
"Dhcp4": { "lease-database": { "type": "mysql", ... }, ... }
```

Next, the name of the database to hold the leases must be set; this is the name used when the database was created (see [First-Time Creation of the MySQL Database](https://kea.readthedocs.io/en/latest/arm/admin.html#mysql-database-create) or [First-Time Creation of the PostgreSQL Database](https://kea.readthedocs.io/en/latest/arm/admin.html#pgsql-database-create)).

For MySQL or PostgreSQL:

```json
"Dhcp4": { "lease-database": { "name": "database-name" , ... }, ... }
```

If the database is located on a different system from the DHCPv4 server, the database host name must also be specified:

```json
"Dhcp4": { "lease-database": { "host": "remote-host-name", ... }, ... }
```

Normally, the database is on the same machine as the DHCPv4 server. In this case, set the value to the empty string:

```json
"Dhcp4": { "lease-database": { "host" : "", ... }, ... }
```

Should the database use a port other than the default, it may be specified as well:

```json
"Dhcp4": { "lease-database": { "port" : 12345, ... }, ... }
```

Should the database be located on a different system, the administrator may need to specify a longer interval for the connection timeout:

```json
"Dhcp4": { "lease-database": { "connect-timeout" : timeout-in-seconds, ... }, ... }
```

The default value of five seconds should be more than adequate for local connections. If a timeout is given, though, it should be an integer greater than zero.

The maximum number of times the server automatically attempts to reconnect to the lease database after connectivity has been lost may be specified:

```json
"Dhcp4": { "lease-database": { "max-reconnect-tries" : number-of-tries, ... }, ... }
```

If the server is unable to reconnect to the database after making the maximum number of attempts, the server will exit. A value of 0 (the default) disables automatic recovery and the server will exit immediately upon detecting a loss of connectivity (MySQL and PostgreSQL only).

The number of milliseconds the server waits between attempts to reconnect to the lease database after connectivity has been lost may also be specified:

```json
"Dhcp4": { "lease-database": { "reconnect-wait-time" : number-of-milliseconds, ... }, ... }
```

The default value for MySQL and PostgreSQL is 0, which disables automatic recovery and causes the server to exit immediately upon detecting the loss of connectivity.

```json
"Dhcp4": { "lease-database": { "on-fail" : "stop-retry-exit", ... }, ... }
```

The possible values are:

- `stop-retry-exit` - disables the DHCP service while trying to automatically recover lost connections. Shuts down the server on failure after exhausting `max-reconnect-tries`. This is the default value for MySQL and PostgreSQL.
- `serve-retry-exit` - continues the DHCP service while trying to automatically recover lost connections. Shuts down the server on failure after exhausting `max-reconnect-tries`.
- `serve-retry-continue` - continues the DHCP service and does not shut down the server even if the recovery fails.

Note:

Automatic reconnection to database backends is configured individually per backend; this allows users to tailor the recovery parameters to each backend they use. We suggest that users enable it either for all backends or none, so behavior is consistent.

Losing connectivity to a backend for which reconnection is disabled results (if configured) in the server shutting itself down. This includes cases when the lease database backend and the hosts database backend are connected to the same database instance.

It is highly recommended not to change the `stop-retry-exit` default setting for the lease manager, as it is critical for the connection to be active while processing DHCP traffic. Change this only if the server is used exclusively as a configuration tool.

The host parameter is used by the MySQL and PostgreSQL backends.

Finally, the credentials of the account under which the server will access the database should be set:

```json
"Dhcp4": { "lease-database": { "user": "user-name",
                               "password": "password",
                              ... },
           ... }
```

If there is no password to the account, set the password to the empty string "". (This is the default.)

#### Tuning Database Timeouts

MySQL exposes two distinct connection options to configure the read and write timeouts. Kea's corresponding `read-timeout` and `write-timeout` configuration parameters specify the timeouts in seconds. For example:

```json
"Dhcp4": { "lease-database": { "read-timeout" : 10, "write-timeout": 20, ... }, ... }
```

Setting these parameters to 0 is equivalent to not specifying them and causes the Kea server to establish a connection to the database with the MySQL defaults. In this case, Kea waits infinitely for the completion of the read and write operations.

MySQL versions earlier than 5.6 do not support setting timeouts for the read and write operations. Moreover, the `read-timeout` and `write-timeout` parameters can only be specified for the MySQL backend. Setting them for any other backend type causes a configuration error.

Use the tcp-user-timeout parameter to set a timeout for PostgreSQL in seconds. For example:

```json
"Dhcp4": { "lease-database": { "tcp-user-timeout" : 10, ... }, ... }
```

Specifying this parameter for other backend types causes a configuration error.

Note:

The timeouts described here are only effective for TCP connections. Please note that the MySQL client library used by the Kea servers typically connects to the database via a UNIX domain socket when the `host` parameter is `localhost` but establishes a TCP connection for `127.0.0.1`.

### Hosts Storage

Kea is also able to store information about host reservations in the database. The hosts database configuration uses the same syntax as the lease database. In fact, the Kea server opens independent connections for each purpose, be it lease or hosts information, which gives the most flexibility. Kea can keep leases and host reservations separately, but can also point to the same database. Currently the supported hosts database types are MySQL and PostgreSQL.

The following configuration can be used to configure a connection to MySQL:

```json
"Dhcp4": {
    "hosts-database": {
        "type": "mysql",
        "name": "kea",
        "user": "kea",
        "password": "secret123",
        "host": "localhost",
        "port": 3306
    }
}
```

Depending on the database configuration, many of the parameters may be optional.

Please note that usage of hosts storage is optional. A user can define all host reservations in the configuration file, and that is the recommended way if the number of reservations is small. However, when the number of reservations grows, it is more convenient to use host storage. Please note that both storage methods (the configuration file and one of the supported databases) can be used together. If hosts are defined in both places, the definitions from the configuration file are checked first and external storage is checked later, if necessary.

Host information can be placed in multiple stores. Operations are performed on the stores in the order they are defined in the configuration file, although this leads to a restriction in ordering in the case of a host reservation addition; read-only stores must be configured after a (required) read-write store, or the addition will fail.

#### DHCPv4 Hosts Database Configuration

Hosts database configuration is controlled through the Dhcp4/hosts-database parameters. If enabled, the type of database must be set to mysql or postgresql.

```json
"Dhcp4": { "hosts-database": { "type": "mysql", ... }, ... }
```

Next, the name of the database to hold the reservations must be set; this is the name used when the lease database was created (see [Supported Backends](https://kea.readthedocs.io/en/latest/arm/admin.html#supported-databases) for instructions on how to set up the desired database type):

```json
"Dhcp4": { "hosts-database": { "name": "database-name" , ... }, ... }
```

If the database is located on a different system than the DHCPv4 server, the database host name must also be specified:

```json
"Dhcp4": { "hosts-database": { "host": remote-host-name, ... }, ... }
```

Normally, the database is on the same machine as the DHCPv4 server. In this case, set the value to the empty string:

```json
"Dhcp4": { "hosts-database": { "host" : "", ... }, ... }
```

Should the database use a port different than the default, it may be specified as well:

```json
"Dhcp4": { "hosts-database": { "port" : 12345, ... }, ... }
```

The maximum number of times the server automatically attempts to reconnect to the host database after connectivity has been lost may be specified:

```json
"Dhcp4": { "hosts-database": { "max-reconnect-tries" : number-of-tries, ... }, ... }
```

If the server is unable to reconnect to the database after making the maximum number of attempts, the server will exit. A value of 0 (the default) disables automatic recovery and the server will exit immediately upon detecting a loss of connectivity (MySQL and PostgreSQL only).

The number of milliseconds the server waits between attempts to reconnect to the host database after connectivity has been lost may also be specified:

```json
"Dhcp4": { "hosts-database": { "reconnect-wait-time" : number-of-milliseconds, ... }, ... }
```

The default value for MySQL and PostgreSQL is 0, which disables automatic recovery and causes the server to exit immediately upon detecting the loss of connectivity.

```json
"Dhcp4": { "hosts-database": { "on-fail" : "stop-retry-exit", ... }, ... }
```

The possible values are:

- `stop-retry-exit` - disables the DHCP service while trying to automatically recover lost connections. Shuts down the server on failure after exhausting `max-reconnect-tries`. This is the default value for MySQL and PostgreSQL.
- `serve-retry-exit` - continues the DHCP service while trying to automatically recover lost connections. Shuts down the server on failure after exhausting `max-reconnect-tries`.
- `serve-retry-continue` - continues the DHCP service and does not shut down the server even if the recovery fails.

Note:

Automatic reconnection to database backends is configured individually per backend. This allows users to tailor the recovery parameters to each backend they use. We suggest that users enable it either for all backends or none, so behavior is consistent.

Losing connectivity to a backend for which reconnection is disabled results (if configured) in the server shutting itself down. This includes cases when the lease database backend and the hosts database backend are connected to the same database instance.

Finally, the credentials of the account under which the server will access the database should be set:

```json
"Dhcp4": { "hosts-database": { "user": "user-name",
                               "password": "password",
                              ... },
           ... }
```

If there is no password to the account, set the password to the empty string `""`. (This is the default.)

The multiple-storage extension uses a similar syntax; a configuration is placed into a `hosts-databases` list instead of into a `hosts-database` entry, as in:

```json
"Dhcp4": { "hosts-databases": [ { "type": "mysql", ... }, ... ], ... }
```

If the same host is configured both in-file and in-database, Kea does not issue a warning, as it would if both were specified in the same data source. Instead, the host configured in-file has priority over the one configured in-database.

#### Using Read-Only Databases for Host Reservations With DHCPv4

In some deployments, the user whose name is specified in the database backend configuration may not have write privileges to the database. This is often required by the policy within a given network to secure the data from being unintentionally modified. In many cases administrators have deployed inventory databases, which contain substantially more information about the hosts than just the static reservations assigned to them. The inventory database can be used to create a view of a Kea hosts database and such a view is often read-only.

Kea host-database backends operate with an implicit configuration to both read from and write to the database. If the user does not have write access to the host database, the backend will fail to start and the server will refuse to start (or reconfigure). However, if access to a read-only host database is required for retrieving reservations for clients and/or assigning specific addresses and options, it is possible to explicitly configure Kea to start in "read-only" mode. This is controlled by the `readonly` boolean parameter as follows:

```json
"Dhcp4": { "hosts-database": { "readonly": true, ... }, ... }
```

Setting this parameter to `false` configures the database backend to operate in "read-write" mode, which is also the default configuration if the parameter is not specified.

Note:

The `readonly` parameter is only supported for MySQL and PostgreSQL databases.

#### Tuning Database Timeouts for Hosts Storage

See [Tuning Database Timeouts](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#tuning-database-timeouts4).

### Interface Configuration

The DHCPv4 server must be configured to listen on specific network interfaces. The simplest network interface configuration tells the server to listen on all available interfaces:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "*" ]
    }
    ...
},
```

The asterisk plays the role of a wildcard and means "listen on all interfaces." However, it is usually a good idea to explicitly specify interface names:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1", "eth3" ]
    },
    ...
}
```

It is possible to use an interface wildcard (*) concurrently with explicit interface names:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1", "eth3", "*" ]
    },
    ...
}
```

This format should only be used when it is desired to temporarily override a list of interface names and listen on all interfaces.

Some deployments of DHCP servers require that the servers listen on interfaces with multiple IPv4 addresses configured. In these situations, the address to use can be selected by appending an IPv4 address to the interface name in the following manner:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1/10.0.0.1", "eth3/192.0.2.3" ]
    },
    ...
}
```

Should the server be required to listen on multiple IPv4 addresses assigned to the same interface, multiple addresses can be specified for an interface as in the example below:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1/10.0.0.1", "eth1/10.0.0.2" ]
    },
    ...
}
```

Alternatively, if the server should listen on all addresses for the particular interface, an interface name without any address should be specified.

Kea supports responding to directly connected clients which do not have an address configured. This requires the server to inject the hardware address of the destination into the data-link layer of the packet being sent to the client. The DHCPv4 server uses raw sockets to achieve this, and builds the entire IP/UDP stack for the outgoing packets. The downside of raw socket use, however, is that incoming and outgoing packets bypass the firewalls (e.g. iptables).

Handling traffic on multiple IPv4 addresses assigned to the same interface can be a challenge, as raw sockets are bound to the interface. When the DHCP server is configured to use the raw socket on an interface to receive DHCP traffic, advanced packet filtering techniques (e.g. the BPF) must be used to receive unicast traffic on the desired addresses assigned to the interface. Whether clients use the raw socket or the UDP socket depends on whether they are directly connected (raw socket) or relayed (either raw or UDP socket).

Therefore, in deployments where the server does not need to provision the directly connected clients and only receives the unicast packets from the relay agents, the Kea server should be configured to use UDP sockets instead of raw sockets. The following configuration demonstrates how this can be achieved:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1", "eth3" ],
        "dhcp-socket-type": "udp"
    },
    ...
}
```

The `dhcp-socket-type` parameter specifies that the IP/UDP sockets will be opened on all interfaces on which the server listens, i.e. "eth1" and "eth3" in this example. If `dhcp-socket-type` is set to `raw`, it configures the server to use raw sockets instead. If the `dhcp-socket-type` value is not specified, the default value `raw` is used.

Using UDP sockets automatically disables the reception of broadcast packets from directly connected clients. This effectively means that UDP sockets can be used for relayed traffic only. When using raw sockets, both the traffic from the directly connected clients and the relayed traffic are handled.

Caution should be taken when configuring the server to open multiple raw sockets on the interface with several IPv4 addresses assigned. If the directly connected client sends the message to the broadcast address, all sockets on this link will receive this message and multiple responses will be sent to the client. Therefore, the configuration with multiple IPv4 addresses assigned to the interface should not be used when the directly connected clients are operating on that link. To use a single address on such an interface, the "interface-name/address" notation should be used.

Note:

Specifying the value raw as the socket type does not guarantee that raw sockets will be used! The use of raw sockets to handle traffic from the directly connected clients is currently supported on Linux and BSD systems only. If raw sockets are not supported on the particular OS in use, the server issues a warning and fall back to using IP/UDP sockets.

In a typical environment, the DHCP server is expected to send back a response on the same network interface on which the query was received. This is the default behavior. However, in some deployments it is desired that the outbound (response) packets be sent as regular traffic and the outbound interface be determined by the routing tables. This kind of asymmetric traffic is uncommon, but valid. Kea supports a parameter called outbound-interface that controls this behavior. It supports two values: the first one, same-as-inbound, tells Kea to send back the response on the same interface where the query packet was received. This is the default behavior. The second parameter, use-routing, tells Kea to send regular UDP packets and let the kernel's routing table determine the most appropriate interface. This only works when dhcp-socket-type is set to udp. An example configuration looks as follows:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1", "eth3" ],
        "dhcp-socket-type": "udp",
        "outbound-interface": "use-routing"
    },
    ...
}
```

Interfaces are re-detected at each reconfiguration. This behavior can be disabled by setting the `re-detect` value to `false`, for instance:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1", "eth3" ],
        "re-detect": false
    },
    ...
}
```

Note that interfaces are not re-detected during `config-test`.

Usually loopback interfaces (e.g. the `lo` or `lo0` interface) are not configured, but if a loopback interface is explicitly configured and IP/UDP sockets are specified, the loopback interface is accepted.

For example, this setup can be used to run Kea in a FreeBSD jail having only a loopback interface, to service a relayed DHCP request:

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "lo0" ],
        "dhcp-socket-type": "udp"
    },
    ...
}
```

Kea binds the service sockets for each interface on startup. If another process is already using a port, then Kea logs the message and suppresses an error. DHCP service runs, but it is unavailable on some interfaces.

The `service-sockets-require-all` option makes Kea require all sockets to be successfully bound. If any opening fails, Kea interrupts the initialization and exits with a non-zero status. (Default is false).

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1", "eth3" ],
        "service-sockets-require-all": true
    },
    ...
}
```

Sometimes, immediate interruption isn't a good choice. The port can be unavailable only temporary. In this case, retrying the opening may resolve the problem. Kea provides two options to specify the retrying: service-sockets-max-retries and service-sockets-retry-wait-time.

The first defines a maximal number of retries that Kea makes to open a socket. The zero value (default) means that the Kea doesn't retry the process.

The second defines a wait time (in milliseconds) between attempts. The default value is 5000 (5 seconds).

```json
"Dhcp4": {
    "interfaces-config": {
        "interfaces": [ "eth1", "eth3" ],
        "service-sockets-max-retries": 5,
        "service-sockets-retry-wait-time": 5000
    },
    ...
}
```

If "service-sockets-max-retries" is non-zero and "service-sockets-require-all" is false, then Kea retries the opening (if needed) but does not fail if any socket is still not opened.

### [Issues With Unicast Responses to DHCPINFORM](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#issues-with-unicast-responses-to-dhcpinform)

Server administrators willing to support DHCPINFORM messages via relays should not block ARP traffic in their networks, or should use raw sockets instead of UDP sockets.

### IPv4 Subnet Identifier

The subnet identifier (subnet ID) is a unique number associated with a particular subnet. In principle, it is used to associate clients' leases with their respective subnets. When a subnet identifier is not specified for a subnet being configured, it is automatically assigned by the configuration mechanism. The identifiers are assigned starting at 1 and are monotonically increased for each subsequent subnet: 1, 2, 3, ....

If there are multiple subnets configured with auto-generated identifiers and one of them is removed, the subnet identifiers may be renumbered. For example: if there are four subnets and the third is removed, the last subnet will be assigned the identifier that the third subnet had before removal. As a result, the leases stored in the lease database for subnet 3 are now associated with subnet 4, something that may have unexpected consequences. The only remedy for this issue at present is to manually specify a unique identifier for each subnet.

Note:

Subnet IDs must be greater than zero and less than 4294967295.

The following configuration assigns the specified subnet identifier to a newly configured subnet:

```json
"Dhcp4": {
    "subnet4": [
        {
            "subnet": "192.0.2.0/24",
            "id": 1024,
            ...
        }
    ]
}
```

This identifier will not change for this subnet unless the `id` parameter is removed or set to 0. The value of 0 forces auto-generation of the subnet identifier.

### IPv4 Subnet Prefix

The subnet prefix is the second way to identify a subnet. Kea can accept non-canonical subnet addresses; for instance, this configuration is accepted:

```json
"Dhcp4": {
    "subnet4": [
        {
           "subnet": "192.0.2.1/24",
            ...
        }
    ]
}
```

This works even if there is another subnet with the "192.0.2.0/24" prefix; only the textual form of subnets are compared to avoid duplicates.

Note:

Abuse of this feature can lead to incorrect subnet selection (see [How the DHCPv4 Server Selects a Subnet for the Client](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcp4-subnet-selection)).

### Configuration of IPv4 Address Pools

The main role of a DHCPv4 server is address assignment. For this, the server must be configured with at least one subnet and one pool of dynamic addresses to be managed. For example, assume that the server is connected to a network segment that uses the 192.0.2.0/24 prefix. The administrator of that network decides that addresses from the range 192.0.2.10 to 192.0.2.20 are going to be managed by the DHCPv4 server. Such a configuration can be achieved in the following way:

```json
"Dhcp4": {
    "subnet4": [
        {
            "subnet": "192.0.2.0/24",
            "pools": [
                { "pool": "192.0.2.10 - 192.0.2.20" }
            ],
            ...
        }
    ]
}
```

Note that `subnet` is defined as a simple string, but the `pools` parameter is actually a list of pools; for this reason, the pool definition is enclosed in square brackets, even though only one range of addresses is specified.

Each `pool` is a structure that contains the parameters that describe a single pool. Currently there is only one parameter, `pool`, which gives the range of addresses in the pool.

It is possible to define more than one pool in a subnet; continuing the previous example, further assume that 192.0.2.64/26 should also be managed by the server. It could be written as 192.0.2.64 to 192.0.2.127, or it can be expressed more simply as 192.0.2.64/26. Both formats are supported by Dhcp4 and can be mixed in the pool list. For example, the following pools could be defined:

```json
"Dhcp4": {
    "subnet4": [
        {
            "subnet": "192.0.2.0/24",
            "pools": [
                { "pool": "192.0.2.10-192.0.2.20" },
                { "pool": "192.0.2.64/26" }
            ],
            ...
        }
    ],
    ...
}
```

White space in pool definitions is ignored, so spaces before and after the comma are optional. They can be used to improve readability.

The number of pools is not limited, but for performance reasons it is recommended to use as few as possible.

The server may be configured to serve more than one subnet. To add a second subnet, use a command similar to the following:

```json
"Dhcp4": {
    "subnet4": [
        {
            "subnet": "192.0.2.0/24",
            "pools": [ { "pool": "192.0.2.1 - 192.0.2.200" } ],
            ...
        },
        {
            "subnet": "192.0.3.0/24",
            "pools": [ { "pool": "192.0.3.100 - 192.0.3.200" } ],
            ...
        },
        {
            "subnet": "192.0.4.0/24",
            "pools": [ { "pool": "192.0.4.1 - 192.0.4.254" } ],
            ...
        }
    ]
}
```

When configuring a DHCPv4 server using prefix/length notation, please pay attention to the boundary values. When specifying that the server can use a given pool, it is also able to allocate the first (typically a network address) and the last (typically a broadcast address) address from that pool. In the aforementioned example of pool 192.0.3.0/24, both the 192.0.3.0 and 192.0.3.255 addresses may be assigned as well. This may be invalid in some network configurations. To avoid this, use the min-max notation.

Note:

Here are some liberties and limits to the values that subnets and pools can take in Kea configurations that are out of the ordinary:

| Kea configuration case | Allowed | Comment |
|------------------------|---------|---------|
| Overlapping subnets | Yes | Administrator should consider how clients are matched to these subnets. |
| Overlapping pools in one subnet | No | Startup error: DHCP4_PARSER_FAIL |
| Overlapping address pools in different subnets | Yes | Specifying the same address pool in different subnets can be used as an equivalent of the global address pool. In that case, the server can assign addresses from the same range regardless of the client's subnet. If an address from such a pool is assigned to a client in one subnet, the same address will be renewed for this client if it moves to another subnet. Another client in a different subnet will not be assigned an address already assigned to the client in any of the subnets. |
| Pools not matching the subnet prefix | No | Startup error: DHCP4_PARSER_FAIL |

### Sending T1 (Option 58) and T2 (Option 59)

According to [RFC 2131](https://tools.ietf.org/html/rfc2131), servers should send values for T1 and T2 that are 50% and 87.5% of the lease lifetime, respectively. By default, `kea-dhcp4` does not send either value; it can be configured to send values that are either specified explicitly or that are calculated as percentages of the lease time. The server's behavior is governed by a combination of configuration parameters, two of which have already been mentioned. To send specific, fixed values use the following two parameters:

- `renew-timer` - specifies the value of T1 in seconds.
- `rebind-timer` - specifies the value of T2 in seconds.

The server only sends T2 if it is less than the valid lease time. T1 is only sent if T2 is being sent and T1 is less than T2; or T2 is not being sent and T1 is less than the valid lease time.

Calculating the values is controlled by the following three parameters.

- `calculate-tee-times` - when true, T1 and T2 are calculated as percentages of the valid lease time. It defaults to false.

- `t1-percent` - the percentage of the valid lease time to use for T1. It is expressed as a real number between 0.0 and 1.0 and must be less than `t2-percent`. The default value is 0.50, per RFC 2131.

- `t2-percent` - the percentage of the valid lease time to use for T2. It is expressed as a real number between 0.0 and 1.0 and must be greater than `t1-percent`. The default value is .875, per RFC 2131.

Note:

In the event that both explicit values are specified and calculate-tee-times is true, the server will use the explicit values. Administrators with a setup where some subnets or shared-networks use explicit values and some use calculated values must not define the explicit values at any level higher than where they will be used. Inheriting them from too high a scope, such as global, will cause them to have explicit values at every level underneath (shared-networks and subnets), effectively disabling calculated values.

### Standard DHCPv4 Options

One of the major features of the DHCPv4 server is the ability to provide configuration options to clients. Most of the options are sent by the server only if the client explicitly requests them using the Parameter Request List option. Those that do not require inclusion in the Parameter Request List option are commonly used options, e.g. "Domain Server", and options which require special behavior, e.g. "Client FQDN", which is returned to the client if the client has included this option in its message to the server.

[List of standard DHCPv4 options configurable by an administrator](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcp4-std-options-list) comprises the list of the standard DHCPv4 options whose values can be configured using the configuration structures described in this section. This table excludes the options which require special processing and thus cannot be configured with fixed values. The last column of the table indicates which options can be sent by the server even when they are not requested in the Parameter Request List option, and those which are sent only when explicitly requested.

The following example shows how to configure the addresses of DNS servers, which is one of the most frequently used options. Options specified in this way are considered global and apply to all configured subnets.

```json
"Dhcp4": {
    "option-data": [
        {
           "name": "domain-name-servers",
           "code": 6,
           "space": "dhcp4",
           "csv-format": true,
           "data": "192.0.2.1, 192.0.2.2"
        },
        ...
    ]
}
```

Note that either `name` or `code` is required; there is no need to specify both. `space` has a default value of `dhcp4`, so this can be skipped as well if a regular (not encapsulated) DHCPv4 option is defined. Finally, `csv-format` defaults to `true`, so it too can be skipped, unless the option value is specified as a hexadecimal string. Therefore, the above example can be simplified to:

```json
"Dhcp4": {
    "option-data": [
        {
           "name": "domain-name-servers",
           "data": "192.0.2.1, 192.0.2.2"
        },
        ...
    ]
}
```

Defined options are added to the response when the client requests them, with a few exceptions which are always added. To enforce the addition of a particular option, set the `always-send` flag to `true` as in:

```json
"Dhcp4": {
    "option-data": [
        {
           "name": "domain-name-servers",
           "data": "192.0.2.1, 192.0.2.2",
           "always-send": true
        },
        ...
    ]
}
```

The effect is the same as if the client added the option code in the Parameter Request List option (or its equivalent for vendor options):

```json
"Dhcp4": {
    "option-data": [
        {
           "name": "domain-name-servers",
           "data": "192.0.2.1, 192.0.2.2",
           "always-send": true
        },
        ...
    ],
    "subnet4": [
        {
           "subnet": "192.0.3.0/24",
           "option-data": [
               {
                   "name": "domain-name-servers",
                   "data": "192.0.3.1, 192.0.3.2"
               },
               ...
           ],
           ...
        },
        ...
    ],
    ...
}
```

The `domain-name-servers` option is always added to responses (the always-send is "sticky"), but the value is the subnet one when the client is localized in the subnet.

The `name` parameter specifies the option name. For a list of currently supported names, see [List of standard DHCPv4 options configurable by an administrator](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcp4-std-options-list) below. The `code` parameter specifies the option code, which must match one of the values from that list. The next line specifies the option space, which must always be set to `dhcp4` as these are standard DHCPv4 options. For other option spaces, including custom option spaces, see [Nested DHCPv4 Options (Custom Option Spaces)](https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html#dhcp4-option-spaces). The next line specifies the format in which the data will be entered; use of CSV (comma-separated values) is recommended. The sixth line gives the actual value to be sent to clients. The data parameter is specified as normal text, with values separated by commas if more than one value is allowed.

Options can also be configured as hexadecimal values. If `csv-format` is set to `false`, option data must be specified as a hexadecimal string. The following commands configure the `domain-name-servers` option for all subnets with the following addresses: 192.0.3.1 and 192.0.3.2. Note that `csv-format` is set to `false`.

```json
"Dhcp4": {
    "option-data": [
        {
            "name": "domain-name-servers",
            "code": 6,
            "space": "dhcp4",
            "csv-format": false,
            "data": "C0 00 03 01 C0 00 03 02"
        },
        ...
    ],
    ...
}
```

Kea supports the following formats when specifying hexadecimal data:

- `Delimited octets` - one or more octets separated by either colons or spaces (":" or " "). While each octet may contain one or two digits, we strongly recommend always using two digits. Valid examples are "ab:cd:ef" and "ab cd ef".

- `String of digits` - a continuous string of hexadecimal digits with or without a "0x" prefix. Valid examples are "0xabcdef" and "abcdef".

Care should be taken to use proper encoding when using hexadecimal format; Kea's ability to validate data correctness in hexadecimal is limited.

It is also possible to specify data for binary options as a single-quoted text string within double quotes as shown (note that `csv-format` must be set to `false`):

```json
"Dhcp4": {
    "option-data": [
        {
            "name": "user-class",
            "code": 77,
            "space": "dhcp4",
            "csv-format": false,
            "data": "'convert this text to binary'"
        },
        ...
    ],
    ...
}
```





















## References
  - Kea Configuration: https://kea.readthedocs.io/en/latest/arm/config.html
  - The DHCPv4 Server: https://kea.readthedocs.io/en/latest/arm/dhcp4-srv.html
