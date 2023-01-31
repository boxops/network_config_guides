Kea Database Installation and Configuration
===========================================

## Installation Notes

This installation guide is focused on Debian Linux distributions, specifically the Ubuntu 22.04.1 LTS server distribution.

### Databases and Schema Versions

Kea may be configured to use a database as storage for leases or as a source of servers' configurations and host reservations (i.e. static assignments of addresses, prefixes, options, etc.). As Kea is updated, new database schemas are introduced to facilitate new features and correct discovered issues with the existing schemas.

## The `kea-admin` Tool

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

## Supported Backends

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

### Option 1: Memfile

The memfile backend is able to store lease information, but cannot store host reservation details; these must be stored in the configuration file. (There are no plans to add a host reservations storage capability to this backend.)

No special initialization steps are necessary for the memfile backend. During the first run, both kea-dhcp4 and kea-dhcp6 create an empty lease file if one is not present. Necessary disk-write permission is required.

### Option 2: MySQL

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

### Option 3: Postgresql

PostgreSQL can store leases, host reservations, and options defined on a per-host basis.

### Install Postgresql

Update the system packages:

```bash
sudo apt -y update
```

Install Postgresql and its dependencies:

```bash
sudo apt install postgresql postgresql-contrib
```

Ensure that the service is started:

```bash
sudo systemctl start postgresql.service
```

Enable the service to start on boot:

```bash
sudo systemctl enable postgresql.service
```

Check the state of the service file:

```bash
sudo systemctl status postgresql.service
```

### First-Time Creation of the PostgreSQL Database

Before preparing any Kea-specific database and tables, the PostgreSQL database must be configured to use the system timezone. It is recommended to use UTC as the timezone for both the system and the PostgreSQL database.

To check the system timezone:

```bash
date +%Z
```

The first task is to create both the database and the user under which the servers will access it. A number of steps are required:

1. Log into PostgreSQL as "root":

```bash
sudo -u postgres psql postgres
```

To check the PostgreSQL timezone:

```bash
show timezone;
```

```bash
SELECT * FROM pg_timezone_names WHERE name = current_setting('TIMEZONE');
```

Usually the setting is configured in the postgresql.conf with the varying version path /etc/postgresql/(version)/main/postgresql.conf, but on some systems the files may be located in /var/lib/pgsql/data.

```bash
timezone = 'UTC'
```



2. Create the database (`database-name` is the name chosen for the database):

```bash
CREATE DATABASE database-name;
```

3. Create the user under which Kea will access the database (and give it a password), then grant it access to the database:

```bash
CREATE USER user-name WITH PASSWORD 'password';
```

```bash
GRANT ALL PRIVILEGES ON DATABASE database-name TO user-name;
```

Exit PostgreSQL:

```bash
\q
```

5. At this point, create the database tables either using the kea-admin tool, as explained in the next section (recommended), or manually. 

#### Option 1: Initialize the PostgreSQL Database Manually

To create the tables manually, enter the following command. PostgreSQL will prompt the administrator to enter the new user's password that was specified in Step 3. When the command completes, Kea will return to the shell prompt. The output should be similar to the following:

```bash
psql -d database-name -U user-name -f path-to-kea/share/kea/scripts/pgsql/dhcpdb_create.pgsql
```

Output:

    Password for user user-name:
    CREATE TABLE
    CREATE INDEX
    CREATE INDEX
    CREATE TABLE
    CREATE INDEX
    CREATE TABLE
    START TRANSACTION
    INSERT 0 1
    INSERT 0 1
    INSERT 0 1
    COMMIT
    CREATE TABLE
    START TRANSACTION
    INSERT 0 1
    COMMIT

(`path-to-kea` is the location where Kea is installed.)

If instead an error is encountered, such as:

```bash
psql: FATAL:  no pg_hba.conf entry for host "[local]", user "user-name", database "database-name", SSL off
```

... the PostgreSQL configuration will need to be altered. Kea uses password authentication when connecting to the database and must have the appropriate entries added to PostgreSQL's pg_hba.conf file. This file is normally located in the primary data directory for the PostgreSQL server. The precise path may vary depending on the operating system and version, but the default location for PostgreSQL is `/etc/postgresql/*/main/postgresql.conf`. However, on some systems (notably CentOS 8), the file may reside in `/var/lib/pgsql/data`.

Assuming Kea is running on the same host as PostgreSQL, adding lines similar to the following should be sufficient to provide password-authenticated access to Kea's database:

```
local   database-name    user-name                                 password
host    database-name    user-name          127.0.0.1/32           password
host    database-name    user-name          ::1/128                password
```

These edits are primarily intended as a starting point, and are not a definitive reference on PostgreSQL administration or database security. Please consult the PostgreSQL user manual before making these changes, as they may expose other databases that are running. It may be necessary to restart PostgreSQL for the changes to take effect.

#### Option 2: Initialize the PostgreSQL Database Using `kea-admin`

If the tables were not created manually, do so now by running the `kea-admin` tool:

**Note: Do not do this if the tables were already created manually!**

```bash
kea-admin db-init pgsql -u database-user -p database-password -n database-name
```

`kea-admin` implements rudimentary checks; it will refuse to initialize a database that contains any existing tables. To start from scratch, all data must be removed manually. (This process is a manual operation on purpose, to avoid accidentally irretrievable mistakes by `kea-admin`.)

### Improved Performance With PostgreSQL

Changing the PostgreSQL internal value `synchronous_commit` from the default value of ON to OFF can result in gain in Kea performance. On slow systems, the gain can be over 1000%. It can be set per-session for testing:

```bash
SET synchronous_commit = OFF;
```

or permanently by command (preffered method):

```bash
ALTER SYSTEM SET synchronous_commit=OFF;
```

or permanently in `/etc/postgresql/[version]/main/postgresql.conf`:

```bash
synchronous_commit = off
```

Be aware that changing this value can cause problems during data recovery after a crash, so we recommend checking the [PostgreSQL documentation](https://www.postgresql.org/docs/current/wal-async-commit.html). With the default value of ON, PostgreSQL writes changes to disk after every INSERT or UPDATE query (in Kea terms, every time a client gets a new lease or renews an existing lease). When `synchronous_commit` is set to OFF, PostgreSQL writes the changes with some delay. Batching writes gives a substantial performance boost. The trade-off, however, is that in the worst-case scenario, all changes in the last moment before crash could be lost. Given the fact that Kea is stable software and crashes very rarely, most deployments find it a beneficial trade-off.

## Limitations Related to the Use of SQL Databases

### Year 2038 Issue

The lease expiration time in Kea is stored in the SQL database for each lease as a timestamp value. Kea developers have observed that the MySQL database does not accept timestamps beyond 2147483647 seconds (the maximum signed 32-bit number) from the beginning of the UNIX epoch (00:00:00 on 1 January 1970). Some versions of PostgreSQL do accept greater values, but the value is altered when it is read back. For this reason, the lease database backends put a restriction on the maximum timestamp to be stored in the database, which is equal to the maximum signed 32-bit number. This effectively means that the current Kea version cannot store leases whose expiration time is later than 2147483647 seconds since the beginning of the epoch (around the year 2038). This will be fixed when database support for longer timestamps is available.


## References
  - Kea Database Administration: https://kea.readthedocs.io/en/latest/arm/admin.html
  - Kea Performance Optimization: https://kb.isc.org/docs/kea-performance-optimization
