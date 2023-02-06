# Purpose:
# Generate a diagram from code using the diagrams package

# Required Packages:
# python3 -m pip install diagrams

# Usage:
# python3 diagram_as_code.py

from diagrams import Cluster, Diagram
from diagrams.custom import Custom
from diagrams.onprem.compute import Server
from diagrams.onprem.database import PostgreSQL
from diagrams.onprem.monitoring import Grafana
from diagrams.onprem.network import Nginx

with Diagram("Kea DHCP High Availability Servers with Kea Stork Monitoring", show=False):
    # stork = Custom("Stork", "stork-square-200px.png")

    with Cluster("VMware vSphere"):
        ingress = Nginx("Ingress")

        with Cluster("dhcp-secondary"):
            secondary_dbv4 = PostgreSQL("Kea PostgreSQL v4")
            secondary_dbv6 = PostgreSQL("Kea PostgreSQL v6")
            secondary_dhcpv4 = Server("Kea DHCPv4")
            secondary_dhcpv6 = Server("Kea DHCPv6")

        with Cluster("dhcp-primary"):
            primary_dbv4 = PostgreSQL("Kea PostgreSQL v4")
            primary_dbv6 = PostgreSQL("Kea PostgreSQL v6")
            primary_dhcpv4 = Server("Kea DHCPv4")
            primary_dhcpv6 = Server("Kea DHCPv6")

        with Cluster("dhcp-monitoring"):
            stork_hooks = Server("Kea Stork Hooks")
            stork_db = PostgreSQL("Stork PostgreSQL")
            stork = Grafana("Stork")

    # connect ingress to primary and secondary
    ingress >> secondary_dhcpv4
    ingress >> secondary_dhcpv6
    ingress >> primary_dhcpv4
    ingress >> primary_dhcpv6
    # connect primary and secondary to primary and secondary db
    primary_dhcpv4 >> primary_dbv4
    primary_dhcpv6 >> primary_dbv6
    secondary_dhcpv4 >> secondary_dbv4
    secondary_dhcpv6 >> secondary_dbv6
    # connect primary_db to stork_hooks and secondary_db to stork_hooks
    primary_dbv4 >> stork_hooks
    primary_dbv6 >> stork_hooks
    secondary_dbv4 >> stork_hooks
    secondary_dbv6 >> stork_hooks
    # connect stork_hooks to stork_db
    stork_hooks >> stork_db
    # connect stork_db to stork
    stork_db >> stork
