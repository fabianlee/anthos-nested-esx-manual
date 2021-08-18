#!/bin/bash

for file in 'vcsa-esxi.json' 'source-govc.sh'; do
  scp -i ../tf-kvm-seedvm/id_rsa $file ubuntu@192.168.140.220:.
done
