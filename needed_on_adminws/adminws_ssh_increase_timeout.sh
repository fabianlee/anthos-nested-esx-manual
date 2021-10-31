#!/bin/bash

echo "Increasing timeout for Admin Workstation so that long-running gkectl commands do not timeout"
sudo sed -i 's/.*ClientAliveInterval.*/ClientAliveInterval 1200/' /etc/ssh/sshd_config
sudo sed -i 's/.*ClientAliveCountMax.*/ClientAliveCountMax 3/' /etc/ssh/sshd_config
sudo systemctl reload sshd
echo "DONE"
