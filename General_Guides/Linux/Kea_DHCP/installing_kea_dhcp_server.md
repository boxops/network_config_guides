Kea DHCP Server Installation Guide
==================================

### Installation Notes

This install guide is focused on Debian Linux distributions, specifically the Ubuntu 22.04.1 LTS server distribution.

ISC offers binary packages of Kea DHCP hosted on [Cloudsmith](https://cloudsmith.io/~isc/repos/).

Why Use ISC's Kea Packages?

1. Update quickly and efficiently directly from the repository, in one step, and skip the added step of downloading and building binaries locally;
2. Get all the latest bug fixes and features immediately, without waiting for your OS distribution to pick up the changes and release them. We provide binary packages along with sources at the time of release (sometimes the binaries are posted a few hours later, but generally the same day).

### Supported Operating Systems

ISC has created packages for the most popular operating systems for production DHCP servers. If your preferred operating system is not packaged, remember you can still build from our published sources.

Providing the following types of packages:
- RPM for RHEL, CentOS, Fedora
- deb for Debian and Ubuntu
- apk for Alpine

### Open Source Package Names

The names of the Debian packages can be found below.

| Open Source Deb Packages | Comment |
|--------------------------|---------|
| isc-kea-admin | This package provides backend database initialization and migration scripts and a DHCP benchmark tool. If you are not using a database backend, you may not need this.
| isc-kea-common | Common libraries for the ISC Kea DHCP server. Install this.
| isc-kea-ctrl-agent | This package provides the REST API service agent for Kea DHCP.
| isc-kea-dev | Development headers for ISC Kea DHCP server. Install if you plan to create any custom Kea hooks.
| isc-kea-dhcp4-server | DHCPv4 server.
| isc-kea-dhcp6-server | DHCPv6 server.
| isc-kea-dhcp-ddns-server | DDNS server.
| isc-kea-doc | Kea documentation. Highly recommended.
| python3-isc-kea-connector | This package is needed for the Kea shell. Optional.
| libfreeradius-client | You will need this if you are using the Kea RADIUS integration.
| libfreeradius-client-dev | For Kea RADIUS integration. Optional.

Debug images are also available: use the package name above +"-dbgsym". For example, isc-kea-common-dbgsym is an alternative to isc-kea-common.

### Premium Package Names (for ISC Support Subscribers)

ISC support subscribers are entitled to additional hooks not included in the open source. Entitlement is based on support level, but the full list of additional hooks available to subscribers is:

| Premium Hook Packages |	Hook name |
|-----------------------|-----------|
| isc-kea-premium-class-cmds | Classification Commands hook library
| isc-kea-premium-cb-cmds | Config Backend Commands hook library
| isc-kea-premium-ddns-tuning | DDNS Tuning hook library
| isc-kea-premium-flex-id | Flexible Identifier hook library
| isc-kea-premium-forensic-log | Forensic Logging hook library
| isc-kea-premium-gss-tsig | GSS-TSIG library
| isc-kea-premium-host-cache | Host Cache hook library
| isc-kea-premium-host-cmds | Host Commands hook library
| isc-kea-premium-lease-query | Leasequery library
| isc-kea-premium-limits | Limits library
| isc-kea-premium-radius | RADIUS hook library
| isc-kea-premium-rbac | Role-Based Access Control
| isc-kea-premium-subnet-cmds | Subnet Commands hook library

## Installation

### Using the Cloudsmith Repositories

All ISC binary packages for Kea are contained in our repositories on [Cloudsmith](https://cloudsmith.io/~isc/repos/). Note that the source tarballs are also available alongside the binary packages for Kea 2.2.0 and later versions. We have both open source repositories, which are available to anyone, and private repositiories for ISC customers, which require a security token to access.

#### Open Source Repositories

Packages can be downloaded from our public Cloudsmith repository by following these directions. These instructions are for Kea 2.2, but they can be easily customized for other versions by changing kea-2-2 in the commands to kea-2-3, etc., as appropriate. The current open source repositories on Cloudsmith are:

| Repository Name | Comments |
|-----------------|----------|
| kea-1-6 | eol stable branch
| kea-1-8 | eol stable branch
| kea-2-0 | old stable branch
| kea-2-2 | current stable branch
| kea-2-3 | current development branch
| keama | migration tool for ISC DHCP migration to Kea
| stork | GUI management tool for Kea

### Update and Upgrade Packages

Be sure to update and upgrade your package manager before installation:

```bash
sudo apt -y update && sudo apt -y dist-upgrade
```

### Setting Up Repos on Debian

To install packages, you can quickly setup the repository automatically (recommended):

```bash
curl -1sLf \
  'https://dl.cloudsmith.io/public/isc/kea-2-2/setup.deb.sh' \
  | sudo -E bash
```

### Installing Kea Packages

After configuring the repositories on a host machine, the Kea packages can be installed. As there are several packages, we can choose to install only the parts of Kea that are required. The dependencies between packages are set up so any dependent packages will be pulled in as well.

The following examples will install the main Kea metapackage which depends on (and consequently installs) all of the components in the Open Source bundle.

```bash
sudo apt -y install isc-kea*
```

If you would like to install other specific components, or subpackages, that is also possible. Please refer to the list of packages above to discover which specific packages you need.

Once Kea is installed, it can be configured; the configuration files are located in the /etc/kea/ folder.

### Managing Kea Services

When using the ISC provided packages, Kea services should be managed using your the service manager of your OS.

Notes:
  - Packages do not include keactrl
  - The keactrl utility is not included in these packages because it is assumed the user would use the operating system's init system to start and stop Kea instead.

### Service Names

| RPM Service Name | Description |
|------------------|-------------|
| isc-kea-dhcp4-server | DHCPv4 Server
| isc-kea-dhcp4-server | DHCPv6 Server
| isc-kea-dhcp4-server | DHCP DDNS Server
| isc-kea-ctrl-agent | Kea Control Agent - REST API

### Service Management

To start, stop, or restart Kea daemons, systemctl should be used on Debian/Ubuntu and RPM based systems, and OpenRC should be used on Alpine.

In the following examples, the kea-dhcp4 service is being enabled, started, and stopped. Please replace kea-dhcp4 with the service you wish to manage.

Enable the Kea daemon:

```bash
sudo systemctl enable isc-kea-dhcp4-server
```

Start the Kea daemon:

```bash
sudo systemctl start isc-kea-dhcp4-server
```

Stop the Kea daemon:

```bash
sudo systemctl stop isc-kea-dhcp4-server
```

Show the status of the Kea daemon:

```bash
sudo systemctl status isc-kea-dhcp4-server
```

## References: 
  - ISC Kea Packages: https://kb.isc.org/docs/isc-kea-packages
  - ISC Kea Official Documentation: https://kea.readthedocs.io/en/latest/index.html
