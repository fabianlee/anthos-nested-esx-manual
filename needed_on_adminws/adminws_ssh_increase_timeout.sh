#!/bin/bash
# https://cloud.google.com/anthos/clusters/docs/on-prem/1.8/known-issues#ssh_connection_closed_by_remote_host

echo "Increasing timeout for Admin Workstation so that long-running gkectl commands do not timeout"
sudo sed -i 's/^ClientAliveInterval.*/ClientAliveInterval 1200/' /etc/ssh/sshd_config
sudo sed -i 's/^ClientAliveCountMax.*/ClientAliveCountMax 15/' /etc/ssh/sshd_config
sudo grep Alive /etc/ssh/sshd_config

sudo systemctl reload sshd
echo "DONE"
