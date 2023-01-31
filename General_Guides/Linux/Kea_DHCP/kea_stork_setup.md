Stork Setup for Monitoring the Kea DHCP Server
==============================================

## Work in Progress...

### Installation Notes

This install guide is focused on Debian Linux distributions, specifically the Ubuntu 22.04.1 LTS server distribution.

Stork can be installed from pre-built packages or from sources; the following sections describe both methods. Unless there is a good reason to compile from sources, installing from native deb or RPM packages is easier and faster.

### Supported Operating Systems

Stork is tested on the following systems:
- Ubuntu 18.04 and 20.04
- Fedora 31 and 32
- CentOS 8
- MacOS 11.3

`stork-server` and `stork-agent` are written in the Go language; the server uses a PostgreSQL database. In principle, the software can be run on any POSIX system that has a Go compiler and PostgreSQL. It is likely the software can also be built on other modern systems, but ISC’s testing capabilities are modest. We encourage users to try running Stork on other OSes not on this list and report their findings to ISC.

### Installation Prerequisites

The Stork agent does not require any specific dependencies to run. It can be run immediately after installation.

Stork uses the `status-get` command to communicate with Kea.

Stork requires the premium Host Commands (`host_cmds`) hook library to be loaded by the Kea instance to retrieve host reservations stored in an external database. Stork works without the Host Commands hook library, but is not able to display host reservations. Stork can retrieve host reservations stored locally in the Kea configuration without any additional hook libraries.

Stork requires the open source Statistics Commands (`stat_cmds`) hook library to be loaded by the Kea instance to retrieve lease statistics. Stork works without the Stat Commands hook library, but is not able to show pool utilization and other statistics.

Stork uses Go implementation to handle TLS connections, certificates, and keys. The secrets are stored in the PostgreSQL database, in the `secret` table.

For the Stork server, a PostgreSQL database (https://www.postgresql.org/) version 10 or later is required. Stork will attempt to run with older versions, but may not work correctly. The general installation procedure for PostgreSQL is OS-specific and is not included here. However, please note that Stork uses pgcrypto extensions, which often come in a separate package. 

### Stork Tool

The `stork-tool` is a program installed with the `Stork Server`, providing commands to set up server’s database and manage TLS certificates. Using this tool is facultative because the server runs the database migrations and creates suitable certificates at startup on its own. However, the tool provides useful commands for inspecting the current database schema version and downgrading to one of the previous versions. In addition, in the [Preparing Stork Server Database](https://stork.readthedocs.io/en/v1.8.0/install.html#setup-server-database) section it is described how the tool can be conveniently used to create a new database and its credentials without a need to run SQL commands directly using the `psql` program.

The [Inspecting Keys and Certificates](https://stork.readthedocs.io/en/v1.8.0/install.html#inspecting-keys-and-certificates) section describes how to use the tool for TLS certificates management.

Further sections describe different methods for installing the Stork Server from packages. See: [Installing on Debian/Ubuntu](https://stork.readthedocs.io/en/v1.8.0/install.html#install-server-deb). The `stork-tool` program is installed from the packages together with the server.

### Preparing the Stork Server Database

Before running `Stork Server`, a PostgreSQL database and the user with suitable privileges must be created. Using the `stork-tool` is the most convenient way to set up the database.

The following command creates a new database `stork` and a user `stork` with all privileges in this database. It also installs the `pgcrypto` extension required by the Stork Server.

```bash
stork-tool db-create --db-name stork --db-user stork
```

By default, `stork-tool` connects to the database as user `postgres`, a default admin role in many PostgreSQL installations. If an installation uses a different administrator name, it can be specified with the `--db-maintenance-user` option. For example:

```bash
stork-tool db-create --db-maintenance-user thomson --db-name stork --db-user stork
```

Similarly, a `postgres` database should often exist in a PostgreSQL installation. However, a different maintenance database can be selected with the `--db-maintenance-name` option.

The `stork-tool` generates a random password to the created database. This password needs to be copied into the server environment file or used in the `stork-server` command line to configure the server to use this password while connecting to the database. Use the `--db-password` option with the `db-create` command to create a user with a specified password.

It is also possible to create the database manually (i.e., using the `psql` tool).

First, connect to PostgreSQL using `psql` and the `postgres` administration user. Depending on the system’s configuration, it may require switching to the user `postgres` first, using the `su postgres` command.

```bash
psql postgres
```

Then, prepare the database:

```bash
CREATE USER stork WITH PASSWORD 'stork';
```

Expected output: CREATE ROLE

```bash
CREATE DATABASE stork;
```

Expected output: CREATE DATABASE

```bash
GRANT ALL PRIVILEGES ON DATABASE stork TO stork;
```

Expected output: GRANT

```bash
\c stork
```

Expected output: You are now connected to database "stork" as user "postgres".

```bash
create extension pgcrypto;
```

Expected output: CREATE EXTENSION

### Generate Database Password

Notes:
  - Make sure the actual password is stronger than “stork”, which is trivial to guess. Using default passwords is a security risk.
  - Stork puts no restrictions on the characters used in the database passwords, nor on their length. In particular, it accepts passwords containing spaces, quotes, double quotes, and other special characters. 
  - Please also consider using the `stork-tool` to generate a random password.

To generate a random password run:

```bash
stork-tool db-password-gen
```

Expected output: generated new database password password=\<random-string\>


TODO
https://stork.readthedocs.io/en/v1.8.0/install.html#installing-from-packages

https://cloudsmith.io/~isc/repos/stork/setup/#formats-deb

curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/stork/setup.deb.sh' \
  | sudo -E bash

Edit the `/etc/stork/agent.env` file:

```
### the IP or hostname to listen on for incoming Stork server connections
STORK_AGENT_HOST=0.0.0.0

### the TCP port to listen on for incoming Stork server connections
STORK_AGENT_PORT=8080
```

Register the agent:

```
dhcpadmin@lab-dhcp-primary:/etc/stork$ sudo su -
root@lab-dhcp-primary:~# su stork-agent -s /bin/sh -c 'stork-agent register -u http://192.168.30.35:8080'
>>>> Server access token (optional):
>>>> IP address or FQDN of the host with Stork Agent (for the Stork Server connection) [lab-dhcp-primary]:
>>>> Port number that Stork Agent will listen on [8080]:
INFO[2023-01-31 16:32:08]         register.go:160   Agent token stored in /var/lib/stork-agent/tokens/agent-token.txt
INFO[2023-01-31 16:32:08]         register.go:161   Agent key, agent token, and CSR (re)generated
INFO[2023-01-31 16:32:08]         register.go:449   =============================================================================
INFO[2023-01-31 16:32:08]         register.go:450   AGENT TOKEN: 27A00ED54612D6C48723076205AA537A5A9E04EEB74A846E10DEF65AA609A3F9
INFO[2023-01-31 16:32:08]         register.go:451   =============================================================================
INFO[2023-01-31 16:32:08]         register.go:454   Authorize the machine in the Stork web UI
INFO[2023-01-31 16:32:08]         register.go:471   Try to register agent in Stork Server
INFO[2023-01-31 16:32:08]         register.go:311   Machine registered
INFO[2023-01-31 16:32:08]         register.go:336   Stored agent-signed cert and CA cert
INFO[2023-01-31 16:32:08]             main.go:132   Registration completed successfully
root@lab-dhcp-primary:~#

```

Certs stored in `/var/lib/stork-agent/certs/` after successful registration.












## References
  - Stork installation guide: https://stork.readthedocs.io/en/v1.8.0/install.html
  - Stork server and agent installation: https://stork.readthedocs.io/en/v1.8.0/install.html#installing-from-packages
  - Cloudsmith Debian repository setup: https://cloudsmith.io/~isc/repos/stork/setup/#formats-deb
