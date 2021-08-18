#!/bin/bash

scp -i ../tf-libvirt/id_rsa ubuntu@192.168.124.220:*.ova .
exit 0

for extensions in sh json yml yaml pem zip ; do
  scp -i ../tf-libvirt/id_rsa ubuntu@192.168.124.220:*.$extensions .
done


