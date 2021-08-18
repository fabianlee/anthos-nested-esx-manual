#!/bin/bash

# vCenter host
export GOVC_URL=vcenter.home.lab
# vCenter credentials
export GOVC_USERNAME=Administrator@vsphere.local
export GOVC_PASSWORD=ExamplePass@456
# disable cert validation
export GOVC_INSECURE=true

govc ls /
#govc datacenter.info
