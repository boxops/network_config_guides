# Generate diagrams

# Usage:
# python diagram_as_code.py

# Required Install:
# python -m pip install graphviz
# python -m pip install diagrams

from diagrams import Cluster, Diagram
from diagrams.aws.compute import ECS
from diagrams.aws.database import ElastiCache, RDS
from diagrams.aws.network import ELB
from diagrams.aws.network import Route53

with Diagram("Clustered Web Services", show=False):
    dns = Route53("DNS")
    lb = ELB("Load Balancer")

    with Cluster("Services"):
        svc_group = [ECS("web1"),
                     ECS("web2"),
                     ECS("web3"),]
    
    with Cluster("Database"):
        db_primary = RDS("UserDB")
        db_primary - [RDS("UserDB RO")]
    
    memcached = ElastiCache("Memcached")

    dns >> lb >> svc_group
    svc_group >> db_primary
    svc_group >> memcached

