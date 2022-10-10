#!/bin/bash

set -x
gsutil cp gs://gke-on-prem-release/gkeadm/1.13.0-gke.525/linux/gkeadm ./

chmod +x gkeadm
./gkeadm version
