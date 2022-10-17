#!/bin/bash
# https://cloud.google.com/anthos/clusters/docs/on-prem/1.8/known-issues#ssh_connection_closed_by_remote_host

echo "Increasing timeout for Admin Workstation so that long-running gkectl commands do not timeout"
sudo sed -i 's/^ClientAliveInterval.*/ClientAliveInterval 60/' /etc/ssh/sshd_config
sudo sed -i 's/^ClientAliveCountMax.*/ClientAliveCountMax 240/' /etc/ssh/sshd_config
sudo grep Alive /etc/ssh/sshd_config

# TMOUT will also cause the ssh client to timeout
cd /etc/profile.d && sudo sed -i 's/TMOUT=.*/TMOUT=600/' $(grep -sr ^TMOUT -l)

sudo systemctl reload sshd
echo "DONE"

echo ""
echo "You MUST exit the ssh session with the Admin Workstation so timeout changes will take affect !!!"
