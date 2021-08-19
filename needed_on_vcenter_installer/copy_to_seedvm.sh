#!/bin/bash

for file in 'vcsa-esxi.json' ; do
  scp -i ../tf-kvm-seedvm/id_rsa $file ubuntu@192.168.140.220:.
done
scp -i ../tf-kvm-seedvm/id_rsa -r ../govc $file ubuntu@192.168.140.220:.
