#!/bin/bash

echo admin workstation
govc vm.power -on $(govc ls /mydc1/vm/admin-ws/gke-admin-ws-*)

echo admin cluster seesaw
for targetvm in $(govc ls /mydc1/vm/seesaw-for-gke-admin*); do
  echo going to power on $targetvm
  govc vm.power -on $targetvm
  sleep 1
done

echo admin cluster master control plane
for targetvm in $(govc ls /mydc1/vm/gke-admin*); do
  echo going to power on $targetvm
  govc vm.power -on $targetvm
  sleep 1
done

echo user cluster control plan
govc vm.power -on $(govc ls /mydc1/vm/user1-*)

