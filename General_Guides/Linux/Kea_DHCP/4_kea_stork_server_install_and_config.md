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

The newly created database is not ready for use until necessary database migrations are executed. The migrations create tables, indexes, triggers, and functions required by the `Stork Server`. As mentioned above, the server can automatically run the migrations at startup, bringing up the database schema to the latest version. However, if a user wants to run the migrations before starting the server, they can use the `stork-tool`:

```bash
stork-tool db-init
```

```bash
stork-tool db-up
```

The server requires the latest database version to run, always runs the migration on its own, and refuses to start if the migration fails for any reason. The migration tool is mostly useful for debugging problems with migration, or for migrating the database without actually running the service. For the complete manual page, please see [stork-tool - A Tool for Managing Stork Server](https://stork.readthedocs.io/en/v1.8.0/man/stork-tool.8.html#man-stork-tool).

## Installing From Packages

Stork packages are stored in repositories located on the [Cloudsmith](https://cloudsmith.io/~isc/repos/stork/packages/) service. Both Debian/Ubuntu and RPM packages may be found there.

Detailed instructions for setting up the operating system to use this repository are available under the `Set Me Up` button on the Cloudsmith repository page.

It is possible to install both `stork-agent` and `stork-server` on the same machine. It is useful in small deployments with a single monitored machine, to avoid setting up a dedicated system for the Stork server. In those cases, however, an operator must consider the potential impact of the stork-server on other services running on the same machine.

### Installing the Stork Server on Debian/Ubuntu

The first step for both Debian and Ubuntu is:

```bash
curl -1sLf 'https://dl.cloudsmith.io/public/isc/stork/cfg/setup/bash.deb.sh' | sudo bash
```

Next, install the Stork server package:

```bash
sudo apt -y install isc-stork-server
```

### Stork Server Setup

Configure the Stork server settings in `/etc/stork/server.env`.

| Note |
|:-----|
| The environment file IS NOT read by default if you run the Stork server manually (without using `systemd`). To load the environment variables from this file you should call the `. /etc/stork/server.env` command before executing the binary (in the same shell instance) or run Stork with the `--use-env-file` switch. |

The following settings are required for the database connection (they have a common `STORK_DATABASE_` prefix):

- `STORK_DATABASE_HOST` - the address of a PostgreSQL database; the default is localhost
- `STORK_DATABASE_PORT` - the port of a PostgreSQL database; the default is 5432
- `STORK_DATABASE_NAME` - the name of a database; the default is stork
- `STORK_DATABASE_USER_NAME` - the username for connecting to the database; the default is stork
- `STORK_DATABASE_PASSWORD` - the password for the username connecting to the database

| Note |
|:-----|
| All of the database connection settings have default values, but we strongly recommend protecting the database with a non-default and hard-to-guess password in the production environment. The `STORK_DATABASE_PASSWORD` setting must be adjusted accordingly. |

The remaining settings pertain to the server’s RESTful API configuration (the `STORK_REST_` prefix):

- `STORK_REST_HOST` - the IP address on which the server listens
- `STORK_REST_PORT` - the port number on which the server listens; the default is 8080
- `STORK_REST_TLS_CERTIFICATE` - a file with a certificate to use for secure connections
- `STORK_REST_TLS_PRIVATE_KEY` - a file with a private key to use for secure connections
- `STORK_REST_TLS_CA_CERTIFICATE` - a certificate authority file used for mutual TLS authentication
- `STORK_REST_STATIC_FILES_DIR` - a directory with static files served in the user interface


| Note |
|:-----|
| The `STORK_REST_STATIC_FILES_DIR` should be set to `/usr/share/stork/www` for the Stork Server installed from the binary packages. It’s the default location for the static content. |
| The Stork agent must trust the REST TLS certificate presented by Stork server. Otherwise, the registration process fails due to invalid Stork Server certificate verification. We strongly recommend using proper, trusted certificates for security reasons. |

The remaining settings pertain to the server’s Prometheus `/metrics` endpoint configuration (the `STORK_SERVER_` prefix is for general purposes):

- `STORK_SERVER_ENABLE_METRICS` - enable the Prometheus metrics collector and /metrics HTTP endpoint

| Warning |
|:-----|
| The Prometheus `/metrics` endpoint does not require authentication. Therefore, securing this endpoint from external access is highly recommended to prevent unauthorized parties from gathering the server’s metrics. One way to restrict endpoint access is by using an appropriate HTTP proxy configuration to allow only local access or access from the Prometheus host. Please consult the NGINX example configuration file shipped with Stork. |

With the settings in place, the Stork server service can now be enabled and started:

```bash
sudo systemctl enable isc-stork-server
```

```bash
sudo systemctl start isc-stork-server
```

To check the status:

```bash
sudo systemctl status isc-stork-server
```

| Note |
|:-----|
| By default, the Stork server web service is exposed on port 8080 and can be tested using a web browser at [http://localhost:8080](http://localhost:8080). To use a different IP address or port, set the `STORK_REST_HOST` and `STORK_REST_PORT` variables in the `/etc/stork/stork.env` file. |

The Stork server can be configured to run behind an HTTP reverse proxy using `Nginx` or `Apache`. The Stork server package contains an example configuration file for `Nginx`, in `/usr/share/stork/examples/nginx-stork.conf`.















## Stork Agent Setup

https://cloudsmith.io/~isc/repos/stork/setup/#formats-deb

### Stork Agent installation from the Cloudsmith package:

curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/stork/setup.deb.sh' \
  | sudo -E bash

#### Install the Stork Agent:

```bash
sudo apt install isc-stork-agent
```

Edit the `/etc/stork/agent.env` file:

```
### the IP or hostname to listen on for incoming Stork server connections
STORK_AGENT_HOST=0.0.0.0

### the TCP port to listen on for incoming Stork server connections
STORK_AGENT_PORT=8080
```

### Enable and start the Stork Agent:

```bash
sudo systemctl enable isc-stork-agent
```

```bash
sudo systemctl start isc-stork-agent
```

To check the status:

```bash
sudo systemctl status isc-stork-agent
```

### Registration With an Agent Token

Register the agent (from the agent terminal) by entering the following (need to be in sudo mode: `sudo su -`):

```bash
su stork-agent -s /bin/sh -c 'stork-agent register -u http://192.168.30.35:8080'
```

Enter the answers to the prompts:

- Token from the Stork Server
- Stork Agent IP or FDQN
- Stork Agent Port (default: 8080)

Output:

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

TODO
https://stork.readthedocs.io/en/v1.8.0/install.html#installing-from-packages











## References
  - Stork installation guide: https://stork.readthedocs.io/en/latest/install.html
  - Stork server and agent installation: https://stork.readthedocs.io/en/latest/install.html#installing-from-packages
  - Cloudsmith Debian repository setup: https://cloudsmith.io/~isc/repos/stork/setup/#formats-deb
