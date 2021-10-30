#!/bin/bash

network=140

# add ssh fingerprint to known_hosts so we don't have to be asked later
ssh-keyscan -H 192.168.$network.220 2>/dev/null >> ~/.ssh/known_hosts

# test forward+reverse DNS resolution
set -ex
ssh -i id_rsa ubuntu@192.168.$network.220 "dig esxi1.home.lab +short; dig -x 192.168.140.236 +short; dig vcenter.home.lab +short; dig -x 192.168.140.237 +short"

# test outside ping to archive.ubuntu.com apt repository
# fails if upstream router for this network not configured with static route for subnet
set -ex
ssh -i id_rsa ubuntu@192.168.$network.220 "dig archive.ubuntu.com +short; ping -c1 archive.ubuntu.com"
set +ex

echo ""
echo ""
echo "DONE. All tests ran successfully"

