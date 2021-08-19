#!/bin/bash
#
# If gkeadm was run with '--auto-creaet-service-accounts' then the admin workstation
# will have the json keys for the 3 additional service accounts
#
# if not, then we need to copy them ourselves from the seedvm
# where at one point they should have been created (i.e. first run of gkeadm)
#

for file in anthos-allowlisted-fabianleeorg.json connect-agent-sa-2108020334.json connect-register-sa-2108020334.json log-mon-sa-2108020334.json; do
  if [ ! -f $file ]; then
    echo $file is not available locally, copying from seedvm
    scp -i ../tf-kvm-seedvm/id_rsa ubuntu@192.168.140.220:~/seedvm/$file .
  fi

  echo copying local $file to admin ws
  scp -i gke-admin-workstation $file ubuntu@192.168.140.221:.
done

