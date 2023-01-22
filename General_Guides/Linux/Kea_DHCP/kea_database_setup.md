Kea Database Setup
==================

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

