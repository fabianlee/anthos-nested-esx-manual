#!/bin/bash
# 
# communicate directly with esxi host (not vcenter)
# start up the vcenter Vm
#

# vCenter host
GOVC_URL=esxi1.home.lab
# vCenter credentials
GOVC_USERNAME=root
GOVC_PASSWORD=ExamplePass@456
# disable cert validation
GOVC_INSECURE=true

nc -w 1 -vz $GOVC_URL 443
if [ $? -eq 0 ]; then
  govc ls /
  govc datacenter.info
else
  echo "WARN: it does not appear that esxi is ready at $GOVC_URL:443"
fi

govc vm.power -on $(govc ls /ha-datacenter/vm/vcenter*)

