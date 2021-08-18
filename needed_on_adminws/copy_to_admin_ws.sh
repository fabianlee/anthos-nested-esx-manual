#!/bin/bash
#
# Overwrite these files on the admin workstation that get auto-generated
# we have filled these out completely already
#

#for file in admin-cluster.yaml admin-hostconfig.yaml seesaw-hostconfig.yaml user-hostconfig.yaml user-seesaw-hostconfig.yaml; do
#  scp -i gke-admin-workstation $file ubuntu@192.168.140.221:
#done
rsync -e "ssh -i gke-admin-workstation" -auvh --progress --include *.yaml . ubuntu@192.168.140.221:

#for file in $(ls *.json); do
#  scp -i gke-admin-workstation $file ubuntu@192.168.140.221:
#done
rsync -e "ssh -i gke-admin-workstation" -auvh --progress --include *.json . ubuntu@192.168.140.221:

rsync -e "ssh -i gke-admin-workstation" -auvh --progress k8s ubuntu@192.168.140.221:
