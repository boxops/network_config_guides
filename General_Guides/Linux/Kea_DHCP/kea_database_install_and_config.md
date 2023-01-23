Kea Database Installation and Configuration
===========================================

### Installation Notes

This install guide is focused on Debian Linux distributions, specifically the Ubuntu 22.04.1 LTS server distribution.

MySQL is the chosen method to store leases for this setup. See the References link below for setting up either PostgreSQL or Memfile for storing leases.

### Databases and Schema Versions

Kea may be configured to use a database as storage for leases or as a source of servers' configurations and host reservations (i.e. static assignments of addresses, prefixes, options, etc.). As Kea is updated, new database schemas are introduced to facilitate new features and correct discovered issues with the existing schemas.

### The `kea-admin` Tool

To manage the databases, Kea provides the `kea-admin` tool. It can initialize a new backend, check its version number, perform a backend upgrade, and dump lease data to a text file.

`kea-admin` takes two mandatory parameters: `command` and `backend`. Additional, non-mandatory options may be specified. The currently supported commands are:

- `db-init` — initializes a new database schema. This is useful during a new Kea installation. The database is initialized to the latest version supported by the version of the software being installed.
- `db-version` — reports the database backend version number. This is not necessarily equal to the Kea version number, as each backend has its own versioning scheme.
- `db-upgrade` — conducts a database schema upgrade. This is useful when upgrading Kea.
- `lease-dump` — dumps the contents of the lease database (for MySQL or PostgreSQL backends) to a CSV (comma-separated values) text file.

The first line of the file contains the column names. This can be used as a way to switch from a database backend to a memfile backend. Alternatively, it can be used as a diagnostic tool, so it provides a portable form of the lease data.

- `lease-upload`— uploads leases from a CSV (comma-separated values) text file to a MySQL or a PostgreSQL lease database. The CSV file needs to be in memfile format.

`backend` specifies the type of backend database. The currently supported types are:

- `memfile` — lease information is stored on disk in a text file.
- `mysql` — information is stored in a MySQL relational database.
- `pgsql` — information is stored in a PostgreSQL relational database.

Additional parameters may be needed, depending on the setup and specific operation: username, password, and database name or the directory where specific files are located. See the appropriate manual page for details (`man 8 kea-admin`).

### Supported Backends

The following table presents the capabilities of available backends. Please refer to the specific sections dedicated to each backend to better understand their capabilities and limitations. Choosing the right backend is essential for the success of the deployment.

#### List of available backends

| Feature | Memfile | MySQL | PostgreSQL |
|---------|---------|-------|------------|
| Status | Stable | Stable | Stable |
| Data format | CSV file | SQL RMDB | SQL RMDB |
| Leases | yes | yes | yes |
| Host reservations | no | yes | yes |
| Options defined on per host basis | no | yes | yes |
| Configuration backend | no | yes | yes |

### Memfile

The memfile backend is able to store lease information, but cannot store host reservation details; these must be stored in the configuration file. (There are no plans to add a host reservations storage capability to this backend.)

No special initialization steps are necessary for the memfile backend. During the first run, both kea-dhcp4 and kea-dhcp6 create an empty lease file if one is not present. Necessary disk-write permission is required.

### MySQL

MySQL is able to store leases, host reservations, options defined on a per-host basis, and a subset of the server configuration parameters (serving as a configuration backend).

#### MySQL Installation

Be sure to update and upgrade your package manager before installation:

```bash
sudo apt -y update && sudo apt -y dist-upgrade
```

Install MySQL server:
```bash
sudo apt -y install mysql-server
```

#### First-Time Creation of the MySQL Database

Before preparing any Kea-specific database and tables, the MySQL database must be configured to use the system timezone. It is recommended to use UTC as the timezone for both the system and the MySQL database.

To check the system timezone:

```bash
date +%Z
```

To check the MySQL timezone:

```bash
SELECT @@system_time_zone;
```

```bash
SELECT @@global.time_zone;
```

```bash
SELECT @@session.time_zone;
```


To configure the MySQL timezone for a specific server, please refer to the installed version documentation.

Usually the setting is configured in the [mysqld] section in `/etc/mysql/my.cnf`, `/etc/mysql/mysql.cnf`, `/etc/mysql/mysqld.cnf`, or `/etc/mysql/mysql.conf.d/mysqld.cnf`.

In this setup, the following was appended to the `/etc/mysql/my.cnf` file:

```bash
[mysqld]
# using default-time-zone
default-time-zone='+00:00'

# or using timezone
timezone='UTC'
```

When setting up the MySQL database for the first time, the database area must be created within MySQL, and the MySQL user ID under which Kea will access the database must be set up. This needs to be done manually, rather than via `kea-admin`.

To create the database:

1. Log into MySQL as "root":
```bash
sudo mysql -u root -p
```

2. Create the MySQL database:
```bash
CREATE DATABASE dhcp;
```

(`dhcp` is the name chosen for the database.)

3. Create the user under which Kea will access the database (and give it a password), then grant it access to the database tables:
```bash
CREATE USER 'keasql'@'localhost' IDENTIFIED BY 'keapassword';
```

```bash
GRANT ALL ON dhcp.* TO 'keasql'@'localhost';
```

(`keasql` and `keapassword` are the user ID and password used to allow Kea access to the MySQL instance. All apostrophes in the command lines above are required.)

4. Create the database.

Exit the MySQL client:
```bash
quit
```

Then use the kea-admin tool to create the database.
```bash
kea-admin db-init mysql -u keasql -p keapassword -n dhcp
```

While it is possible to create the database from within the MySQL client, we recommend using the `kea-admin` tool as it performs some necessary validations to ensure Kea can access the database at runtime. Among those checks is verification that the schema does not contain any pre-existing tables; any pre-existing tables must be removed manually. An additional check examines the user's ability to create functions and triggers. The following error indicates that the user does not have the necessary permissions to create functions or triggers:

    ERROR 1419 (HY000) at line 1: You do not have the SUPER privilege and binary logging is
    enabled (you *might* want to use the less safe log_bin_trust_function_creators variable)
    ERROR/kea-admin: mysql_can_create cannot trigger, check user permissions, mysql status = 1
    mysql: [Warning] Using a password on the command line interface can be insecure.
    ERROR/kea-admin: Create failed, the user, keatest, has insufficient privileges.

The simplest way around this is to set the global MySQL variable, `log_bin_trust_function_creators`, to 1 via the MySQL client. Note this must be done as a user with SUPER privileges:

```bash
set @@global.log_bin_trust_function_creators = 1;
```

5. Exit MySQL:
```bash
quit
```

### Improved Performance With MySQL

Changing the MySQL internal value `innodb_flush_log_at_trx_commit` from the default value of 1 to 2 can result in a huge gain in Kea performance. In some deployments, the gain was over 1000% (10 times faster when set to 2, compared to the default value of 1). It can be set per-session for testing:

```bash
SET GLOBAL innodb_flush_log_at_trx_commit=2;
```

```bash
SHOW SESSION VARIABLES LIKE 'innodb_flush_log%';
```

or permanently in /etc/mysql/my.cnf:

```bash
[mysqld]
innodb_flush_log_at_trx_commit=2
```

Be aware that changing this value can cause problems during data recovery after a crash, so we recommend checking the MySQL documentation. With the default value of 1, MySQL writes changes to disk after every INSERT or UPDATE query (in Kea terms, every time a client gets a new lease or renews an existing lease). When innodb_flush_log_at_trx_commit is set to 2, MySQL writes the changes at intervals no longer than 1 second. Batching writes gives a substantial performance boost. The trade-off, however, is that in the worst-case scenario, all changes in the last second before crash could be lost. Given the fact that Kea is stable software and crashes very rarely, most deployments find it a beneficial trade-off.

## References
  - Kea Database Administration: https://kea.readthedocs.io/en/latest/arm/admin.html
  - Kea Performance Optimization: https://kb.isc.org/docs/kea-performance-optimization

