#!/bin/bash

set -x
gsutil cp gs://gke-on-prem-release/gkeadm/1.8.5-gke.3/linux/gkeadm ./

chmod +x gkeadm
./gkeadm version
