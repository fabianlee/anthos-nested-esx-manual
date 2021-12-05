#!/bin/bash

set -x
gsutil cp gs://gke-on-prem-release/gkeadm/1.9.2-gke.4/linux/gkeadm ./

chmod +x gkeadm
./gkeadm version
