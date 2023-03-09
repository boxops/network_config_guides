# Purpose:
# Generate a diagram from code using the diagrams package

# Required Packages:
# python3 -m pip install diagrams
# sudo apt install graphviz

# Usage:
# python3 diagram_as_code.py

from diagrams import Cluster, Diagram
from diagrams.onprem.compute import Server
from diagrams.generic.network import Firewall
from diagrams.generic.storage import Storage
from diagrams.aws.general import InternetAlt2

with Diagram("Kea DHCP HA Servers with Kea Stork Monitoring", show=False):
    cloud = InternetAlt2("Cloud")

    with Cluster("Datacenter 1"):
        ingress1 = Firewall("Ingress")
        with Cluster("VMware vSphere"):
            with Cluster("dhcp-primary"):
                primary_db = Storage("PostgreSQL")
                primary_dhcp = Server("DHCP")

    with Cluster("Datacenter 2"):
        ingress2 = Firewall("Ingress")
        with Cluster("VMware vSphere"):
            with Cluster("dhcp-secondary"):
                secondary_db = Storage("PostgreSQL")
                secondary_dhcp = Server("DHCP")

    with Cluster("VMware vSphere"):
        with Cluster("dhcp-monitoring"):
            stork_db = Storage("PostgreSQL")
            stork = Server("Stork")

    # connect cloud to both ingress
    cloud - ingress1
    cloud - ingress2
    # connect ingress to primary and secondary
    ingress1 - primary_dhcp - primary_db
    ingress2 - secondary_dhcp - secondary_db
    # connect primary and secondary to stork
    primary_dhcp - stork
    secondary_dhcp - stork
    # connect stork_db to stork
    stork_db - stork
