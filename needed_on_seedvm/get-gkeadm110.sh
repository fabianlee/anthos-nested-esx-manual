#!/bin/bash

set -x
gsutil cp gs://gke-on-prem-release/gkeadm/1.10.0-gke.194/linux/gkeadm ./

chmod +x gkeadm
./gkeadm version
