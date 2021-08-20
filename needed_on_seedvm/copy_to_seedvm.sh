#!/bin/bash
#
# copy files to seed vm
#

# make remote dir
ssh -i ../tf-kvm-seedvm/id_rsa ubuntu@192.168.140.220 "mkdir -p ~/seedvm"
# then sync to it
rsync -e "ssh -i ../tf-kvm-seedvm/id_rsa" -auvh --progress * ubuntu@192.168.140.220:~/seedvm
