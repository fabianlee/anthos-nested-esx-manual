#!/bin/bash

set -ex

# get email address form
newServiceAccount="anthos-allowlisted"
accountEmail=$(gcloud iam service-accounts list --project=$projectId --filter=$newServiceAccount --format="value(email)")

gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/serviceusage.serviceUsageViewer"

gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/iam.serviceAccountCreator"

gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/iam.roleViewer"

# was not asked for in 1.4 docs, but am having problems with back-off pulling image during admin cluster creation so trying this additional role
gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/storage.objectViewer"
