#!/bin/bash

# this 'ubuntu-focal' template does not have an ssh login key, just password
# so use sshpass
sudo apt install sshpass -y

password=ExamplePass@456

set -x
for octet in $(seq 140 142); do
  echo octet $octet
  ssh-keyscan -H 192.168.$octet.51 2>/dev/null >> ~/.ssh/known_hosts
  sshpass -p $password ssh ubuntu@192.168.$octet.51 "nc -vz 192.168.140.51 22; nc -vz 192.168.141.51 22; nc -vz 192.168.142.51 22; nslookup esxi1.home.lab"
done

# test forward+reverse DNS resolution
set -ex
for network in $(seq 140 142); do 
  sshpass -p $password ssh ubuntu@192.168.$network.51 "dig esxi1.home.lab +short; dig -x 192.168.140.236 +short; dig vcenter.home.lab +short; dig -x 192.168.140.237 +short"
done
set +ex

# test outside ping to archive.ubuntu.com apt repository
# fails if upstream router for this network not configured with static route for subnet
set -ex
for network in $(seq 140 142); do 
  sshpass -p $password ssh ubuntu@192.168.$network.51 "dig archive.ubuntu.com +short; ping -c1 archive.ubuntu.com"
done
set +ex

echo ""
echo ""
echo "DONE. All tests ran successfully"

