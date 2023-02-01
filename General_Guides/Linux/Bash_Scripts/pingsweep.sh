
#!/bin/bash

# Sweeps a /24 network with ping -c 1 -i 0.2 <ip>
# Run the script with an argument e.g. (./pingsweep 192.168.1)
# Optional - Write output to a file e.g. (./pingsweep 192.168.1 > iplist.txt)

for ip in `seq 1 254`; do
        ping -c 1 -i 0.2 $1.$ip | grep "64 bytes" | cut -d " " -f 4 | tr -d ":" &
done
