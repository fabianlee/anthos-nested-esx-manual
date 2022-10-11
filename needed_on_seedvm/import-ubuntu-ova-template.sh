#!/bin/bash
# https://cloud.google.com/anthos/clusters/docs/on-prem/latest/how-to/manual-import-ova

version="${1:-1.13.0-gke.525}"

if [[ ! -f gke-on-prem-ubuntu-${version}.ova ]]; then
  gsutil cp gs://gke-on-prem-release/node-os-ubuntu/gke-on-prem-ubuntu-${version}.ova ./
else
  echo "already downloaded gke-on-prem-ubuntu-${version}.ova"
fi

# gkectl will look in admin-ws folder
govc import.ova -folder=admin-ws -options - gke-on-prem-ubuntu-${version}.ova <<EOF
{
  "DiskProvisioning": "thin",
  "MarkAsTemplate": true
}
EOF

