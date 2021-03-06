#!/bin/bash

# add ssh fingerprint to known_hosts so we don't have to be asked later
for network in $(seq 140 142); do 
  ssh-keyscan -H 192.168.$network.10 2>/dev/null >> ~/.ssh/known_hosts
done

# test connectivity to each other
set -ex
for network in $(seq 140 142); do 
  ssh -i id_rsa ubuntu@192.168.$network.10 "nc -vz 192.168.140.10 22; nc -vz 192.168.141.10 22; nc -vz 192.168.142.10 22;"
done
set +ex

# test forward+reverse DNS resolution
set -ex
for network in $(seq 140 142); do 
  ssh -i id_rsa ubuntu@192.168.$network.10 "dig esxi1.home.lab +short; dig -x 192.168.140.236 +short; dig vcenter.home.lab +short; dig -x 192.168.140.237 +short"
done
set +ex

# test outside ping to archive.ubuntu.com apt repository
# fails if upstream router for this network not configured with static route for subnet
set -ex
for network in $(seq 140 142); do 
  ssh -i id_rsa ubuntu@192.168.$network.10 "dig archive.ubuntu.com +short; ping -c1 archive.ubuntu.com"
done
set +ex

echo ""
echo ""
echo "DONE. All tests ran successfully"

