#!/bin/bash
#
# Overwrite these files on the admin workstation that get auto-generated
# we have filled these out completely already
#

# provide extra copy because check-config will overwrite
cp admin-cluster.yaml admin-cluster-filledin.yaml
rsync -e "ssh -i gke-admin-workstation" -auvh --progress --include *.yaml . ubuntu@192.168.140.221:

rsync -e "ssh -i gke-admin-workstation" -auvh --progress --include *.json . ubuntu@192.168.140.221:

rsync -e "ssh -i gke-admin-workstation" -auvh --progress k8s ubuntu@192.168.140.221:
