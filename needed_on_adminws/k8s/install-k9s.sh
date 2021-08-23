#!/bin/bash

# docker ppa changed its label, apt can fix this (apt-get cannot)
set -ex
sudo apt update -y
set +ex

sudo apt install jq -y
curver=$(curl -sL https://api.github.com/repos/derailed/k9s/releases/latest | jq -r ".tag_name")
wget https://github.com/derailed/k9s/releases/download/$curver/k9s_Linux_x86_64.tar.gz

tar xvfz k9s_Linux_x86_64.tar.gz
rm LICENSE README.md

sudo cp k9s /usr/local/bin/.
sudo chmod +x /usr/local/bin/k9s
