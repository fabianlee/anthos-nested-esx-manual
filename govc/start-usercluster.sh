#!/bin/bash

source ./source-govc-vars.sh

nc -w 1 -vz $GOVC_URL 443
if [ $? -ne 0 ]; then
  echo "WARN: it does not appear that vcenter is ready at $GOVC_URL:443"
  exit 3
fi

govc ls /
if [ $? -ne 0 ]; then
  echo "WARN: vcenter is up but not ready at $GOVC_URL:443"
  exit 3
fi

echo user cluster seesaw
govc vm.power -on $(govc ls /mydc1/vm/seesaw-for-user*)

echo user cluster
for targetvm in $(govc ls /mydc1/vm/pool-1-*); do
  echo going to power on $targetvm
  govc vm.power -on $targetvm
  sleep 1
done



