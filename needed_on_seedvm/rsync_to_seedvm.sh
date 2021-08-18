#!/bin/bash
#
# copy files to seed vm
#

ssh -i ../tf-kvm-seedvm/id_rsa ubuntu@192.168.140.220 "mkdir -p ~/seedvm"

rsync -e "ssh -i ../tf-kvm-seedvm/id_rsa" -auvh --progress * ubuntu@192.168.140.220:~/seedvm

#for file in $(ls *.json); do
#  scp -i ../tf-libvirt/id_rsa $file ubuntu@192.168.140.220:.
#done

