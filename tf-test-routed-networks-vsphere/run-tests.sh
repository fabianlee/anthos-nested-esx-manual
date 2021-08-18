#!/bin/bash

password=ExamplePass@456

set -x
for octet in $(seq 140 142); do
  echo octet $octet
  ssh-keyscan -H 192.168.$octet.51 2>/dev/null >> ~/.ssh/known_hosts
  sshpass -p $password ssh ubuntu@192.168.$octet.51 "nc -vz 192.168.140.51 22; nc -vz 192.168.141.51 22; nc -vz 192.168.142.51 22; nslookup esxi1.home.lab"
done

