#!/bin/bash
#
# Overwrite these files on the admin workstation that get auto-generated
# we have filled these out completely already
#

# copy yaml templates (not putting -u, which would only copy newer)
# want to always copy our prepared templates over the top of what's there
rsync -e "ssh -i gke-admin-workstation" -avh --progress --exclude '*.j2' --exclude 14 --exclude 18 --include adminws_ssh_increase_timeout.sh --include '*.yaml' --include '*.json' . ubuntu@192.168.140.221:

# copy entire k8s folder (folder created automatically, no need to create)
rsync -e "ssh -i gke-admin-workstation" -auvh --progress k8s ubuntu@192.168.140.221:
