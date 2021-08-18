#!/bin/bash
#
# Usage: source ./source-govc-vars.sh
#
# exports variables needed to use govc by looking at terraform variables file
#
BIN_DIR=$(dirname ${BASH_SOURCE[0]})
. "$BIN_DIR/common.sh"

tfvars=$BIN_DIR/tf-vsphere-singlevm/terraform.tfvars

############## MAIN ##################

# vCenter host
export GOVC_URL=$(getTFVal $tfvars vsphere_server)
# vCenter credentials
export GOVC_USERNAME=$(getTFVal $tfvars vsphere_user)
export GOVC_PASSWORD=$(getTFVal $tfvars vsphere_password)
# disable cert validation
export GOVC_INSECURE=true

govc ls /
govc datacenter.info
