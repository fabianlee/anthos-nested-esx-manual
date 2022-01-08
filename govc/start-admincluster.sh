#!/bin/bash

source ./source-govc-vars.sh

vcenter_available=0
while [ $vcenter_available -eq 0 ]; do
  nc -w 1 -vz $GOVC_URL 443
  if [ $? -ne 0 ]; then
    echo "WARN: it does not appear that vcenter is ready at $GOVC_URL:443"
    sleep 10
    vcenter_available=0
  else
    vcenter_available=1
  fi
done

vcenter_available=0
while [ $vcenter_available -eq 0 ]; do
  govc ls /
  if [ $? -ne 0 ]; then
    echo "WARN: vcenter is up but not ready at $GOVC_URL:443"
    sleep 10
    vcenter_available=0
  else
    vcenter_available=1
  fi
done

echo waiting 60 seconds for settling
sleep 60

echo admin workstation
govc vm.power -on $(govc ls /mydc1/vm/admin-ws/gke-admin-ws*)

echo admin cluster seesaw
for targetvm in $(govc ls /mydc1/vm/seesaw-for-gke-admin*); do
  echo going to power on $targetvm
  govc vm.power -on $targetvm
  sleep 1
done

echo admin cluster master control plane
for targetvm in $(govc ls /mydc1/vm/gke-admin*); do
  # skip template
  if [[ $targetvm =~ tmpl$ ]]; then
    echo "going to skip $targetvm"
    continue
  fi
  echo going to power on $targetvm
  govc vm.power -on $targetvm
  sleep 1
done

echo user cluster control plan
govc vm.power -on $(govc ls /mydc1/vm/user1-*)

