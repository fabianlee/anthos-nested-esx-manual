#!/bin/bash

for octet in $(seq 140 142); do
  ssh-keygen -f "$HOME/.ssh/known_hosts" -R 192.168.$octet.51
done
