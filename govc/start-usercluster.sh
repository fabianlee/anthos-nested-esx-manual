#!/bin/bash

echo user cluster seesaw
govc vm.power -on $(govc ls /mydc1/vm/seesaw-for-user*)

echo user cluster
for targetvm in $(govc ls /mydc1/vm/pool-1-*); do
  echo going to power on $targetvm
  govc vm.power -on $targetvm
  sleep 1
done



