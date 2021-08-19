#!/bin/bash
#
# Overwrite these files on the admin workstation that get auto-generated
# we have filled these out completely already
#

# copy yaml templates
rsync -e "ssh -i gke-admin-workstation" -auvh --progress --include *.yaml . ubuntu@192.168.140.221:

# copy json keys
rsync -e "ssh -i gke-admin-workstation" -auvh --progress ../needed_on_seedvm/*.json ubuntu@192.168.140.221:
rsync -e "ssh -i gke-admin-workstation" -auvh --progress --include *.json . ubuntu@192.168.140.221:

# copy entire k8s folder (folder created automatically, no need to create)
rsync -e "ssh -i gke-admin-workstation" -auvh --progress k8s ubuntu@192.168.140.221:
