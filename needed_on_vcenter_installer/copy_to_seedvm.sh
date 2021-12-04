#!/bin/bash
#
# copy files over to seedVM
#

# copy json file for vcenter setup
for file in 'vcsa-esxi.json' ; do
  scp -i ../tf-kvm-seedvm/id_rsa $file ubuntu@192.168.140.220:.
done

# copy govc related files
scp -i ../tf-kvm-seedvm/id_rsa -r ../govc $file ubuntu@192.168.140.220:.
