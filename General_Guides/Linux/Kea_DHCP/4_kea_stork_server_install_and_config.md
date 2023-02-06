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

#### Securing the Database Connection

The PostgreSQL server can be configured to encrypt communications between the clients and the server. Detailed information on how to enable encryption on the database server, and how to create the suitable certificate and key files, is available in the [PostgreSQL documentation](https://www.postgresql.org/docs/14/ssl-tcp.html).

The Stork server supports secure communications with the database. The following configuration settings in the `server.env` file enable and configure communication encryption with the database server. They correspond with the SSL settings provided by `libpq` - the native PostgreSQL client library written in C:

- `STORK_DATABASE_SSLMODE` - the SSL mode for connecting to the database (i.e., `disable`, `require`, `verify-ca`, or `verify-full`); the default is `disable`
- `STORK_DATABASE_SSLCERT` - the location of the SSL certificate used by the server to connect to the database
- `STORK_DATABASE_SSLKEY` - the location of the SSL key used by the server to connect to the database
- `STORK_DATABASE_SSLROOTCERT` - the location of the root certificate file used to verify the database server’s certificate

The default SSL mode setting, `disable`, configures the server to use unencrypted communication with the database. Other settings have the following meanings:

- `require` - use secure communication but do not verify the server’s identity unless the root certificate location is specified and that certificate exists. If the root certificate exists, the behavior is the same as in the case of `verify-ca`.
- `verify-ca` - use secure communication and verify the server’s identity by checking it against the root certificate stored on the Stork server machine.
- `verify-full` - use secure communication and verify the server’s identity against the root certificate. In addition, check that the server hostname matches the name stored in the certificate.

Specifying the SSL certificate and key location is optional. If they are not specified, the Stork server uses the ones from the current user’s home directory: `~/.postgresql/postgresql.crt` and `~/.postgresql/postgresql.key`. If they are not present, Stork tries to find suitable keys in common system locations.

### Installing the Stork Agent

There are two ways to install the packaged Stork agent on a monitored machine. The first method is to use the [Cloudsmith](https://cloudsmith.io/~isc/repos/stork/setup/#formats-deb) repository, as with the Stork server installation. The second method, supported since Stork 0.15.0, is to use an installation script provided by the Stork server, which downloads the agent packages embedded in the server package. The preferred installation method depends on the selected agent registration type. Supported registration methods are described in [Securing Connections Between the Stork Server and a Stork Agent](https://stork.readthedocs.io/en/v1.8.0/install.html#secure-server-agent).

#### Stork Agent installation from the Cloudsmith package:

```bash
curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/stork/setup.deb.sh' \
  | sudo -E bash
```

#### Install the Stork Agent:

```bash
sudo apt install isc-stork-agent
```

#### Agent Configuration Settings

The following are the Stork agent configuration settings available in the `/etc/stork/agent.env` file after installing the package. All these settings use the `STORK_AGENT_` prefix to indicate that they configure the Stork agent. Configuring Stork using the environment variables is recommended for deployments using `systemd`.

| Note |
|:-----|
| The environment file IS NOT read by default if you run the Stork agent manually (without using `systemd`). To load the environment variables from this file you should call the `. /etc/stork/agent.env` command before executing the binary (in the same shell instance) or run Stork with the `--use-env-file` switch. |

The general settings:

- `STORK_AGENT_HOST` - the IP address of the network interface or DNS name which `stork-agent` should use to receive connections from the server; the default is `0.0.0.0` (i.e. listen on all interfaces)
- `STORK_AGENT_PORT` - the port number the agent should use to receive connections from the server; the default is `8080`
- `STORK_AGENT_LISTEN_STORK_ONLY` - this enables Stork functionality only, i.e. disables Prometheus exporters; the default is `false`
- `STORK_AGENT_LISTEN_PROMETHEUS_ONLY` - this enables the Prometheus exporters only, i.e. disables Stork functionality; the default is `false`
- `STORK_AGENT_SKIP_TLS_CERT_VERIFICATION` - this skips TLS certificate verification when `stork-agent` connects to Kea over TLS and Kea uses self-signed certificates; the default is `false`

The following settings are specific to the Prometheus exporters:

- `STORK_AGENT_PROMETHEUS_KEA_EXPORTER_ADDRESS` - the IP address or hostname the agent should use to receive the connections from Prometheus fetching Kea statistics; default is `0.0.0.0`
- `STORK_AGENT_PROMETHEUS_KEA_EXPORTER_PORT` - the port the agent should use to receive connections from Prometheus when fetching Kea statistics; the default is `9547`
- `STORK_AGENT_PROMETHEUS_KEA_EXPORTER_INTERVAL` - specifies how often the agent collects stats from Kea, in seconds; default is `10`
- `STORK_AGENT_PROMETHEUS_KEA_EXPORTER_PER_SUBNET_STATS` - enable or disable collecting per subnet stats from Kea; default is `true` (collecting enabled). You can use this option to limit the data passed to Prometheus/Grafana in large networks.
- `STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_ADDRESS` - the IP address or hostname the agent should use to receive the connections from Prometheus fetching BIND9 statistics; default is `0.0.0.0` to listen on for incoming Prometheus connection; default is `0.0.0.0`
- `STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_PORT` - the port the agent should use to receive the connections from Prometheus fetching BIND9 statistics; default is `9119`
- `STORK_AGENT_PROMETHEUS_BIND9_EXPORTER_INTERVAL` - specifies how often the agent collects stats from BIND9, in seconds; default is `10`

The last setting is used only when Stork agents register in the Stork server using an agent token:

- `STORK_AGENT_SERVER_URL` - the `stork-server` URL used by the agent to send REST commands to the server during agent registration

| Warning |
|:--------|
| `stork-server` does not currently support communication with `stork-agent` via an IPv6 link-local address with zone ID (e.g., `fe80::%eth0`). This means that the `STORK_AGENT_HOST` variable must be set to a DNS name, an IPv4 address, or a non-link-local IPv6 address. |

#### Minimal Agent Configuration

Edit the `/etc/stork/agent.env` file:

```
### the IP or hostname to listen on for incoming Stork server connections
STORK_AGENT_HOST=0.0.0.0

### the TCP port to listen on for incoming Stork server connections
STORK_AGENT_PORT=8080
```

Enable and start the Stork Agent:

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

### Securing Connections Between the Stork Server and a Stork Agent

Connections between the server and the agents are secured using standard cryptography solutions, i.e. PKI and TLS.

The server generates the required keys and certificates during its first startup. They are used to establish safe, encrypted connections between the server and the agents with authentication at both ends of these connections. The agents use the keys and certificates generated by the server to create agent-side keys and certificates, during the agents’ registration procedure described in the next sections. The private key and CSR certificate generated by an agent and signed by the server are used for authentication and connection encryption.

An agent can be registered in the server using one of the two supported methods:

1. using an agent token
2. using a server token

In the first case, an agent generates a token and passes it to the server requesting registration. The server associates the token with the particular agent. A Stork super administrator must approve the registration request in the web UI, ensuring that the token displayed in the UI matches the agent’s token in the logs. The Stork agent is typically installed from the Cloudsmith repository when this registration method is used.

In the second registration method, a server generates a common token for all new registrations. The super admin must copy the token from the UI and paste it into the agent’s terminal during the interactive agent registration procedure. This registration method does not require any additional approval of the agent’s registration request in the web UI. If the pasted server token is correct, the agent should be authorized in the UI when the interactive registration completes. When this registration method is used, the Stork agent is typically installed using a script that downloads the agent packages embedded in the server.

The applicability of the two methods is described in [Registration Methods Summary](https://stork.readthedocs.io/en/v1.8.0/install.html#registration-methods-summary).

The installation and registration processes using each method are described in the subsequent sections.

#### Securing Connections Between `stork-agent` and the Kea Control Agent

The Kea Control Agent (CA) may be configured to accept connections only over TLS. It requires specifying `trust-anchor`, `cert-file` and `key-file` values in the `kea-ctrl-agent.conf` file. For details, see the [Kea Administrator Reference Manual](https://kea.readthedocs.io/en/latest/index.html).

The Stork agent can communicate with Kea over TLS, via the same certificates that it uses in communication with the Stork server.

The Stork agent by default requires that the Kea Control Agent provide a trusted TLS certificate. If Kea uses a self-signed certificate, the Stork agent can be launched with the `--skip-tls-cert-verification` flag or `STORK_AGENT_SKIP_TLS_CERT_VERIFICATION` environment variable set to 1, to disable Kea certificate verification.

The Kea CA accepts only requests signed with a trusted certificate, when the `cert-required` parameter is set to `true` in the Kea CA configuration file. In this case, the Stork agent must use valid certificates; it cannot use self-signed certificates created during Stork agent registration.

Kea 1.9.0 added support for basic HTTP authentication to control access for incoming REST commands over HTTP. If the Kea CA is configured to use Basic Auth, valid credentials must be provided in the Stork agent credentials file: `/etc/stork/agent-credentials.json`.

By default, this file does not exist, but the `/etc/stork/agent-credentials.json.template` file provides example data. The template file can be renamed by removing the `.template` suffix; then the file can be edited and valid credentials can be provided. The `chown` and `chmod` commands should be used to set the proper permissions; this file contains the secrets, and should be readable/writable only by the user running the Stork agent and any administrators.

| Warning |
|:--------|
| Basic HTTP authentication is weak on its own as there are known dictionary attacks, but those attacks require a “man in the middle” to get access to the HTTP traffic. That can be eliminated by using basic HTTP authentication exclusively over TLS. In fact, if possible, using client certificates for TLS is better than using basic HTTP authentication. |

For example:

```json
{
   "basic_auth": [
      {
         "ip": "127.0.0.1",
         "port": 8000,
         "user": "foo",
         "password": "bar"
      }
   ]
}
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
