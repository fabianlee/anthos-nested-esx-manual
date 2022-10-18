#!/bin/bash
# https://cloud.google.com/anthos/clusters/docs/on-prem/latest/how-to/service-accounts#granting_roles_to_your_component_access_service_account

set -ex

# get email address form
newServiceAccount="component-access-sa"
accountEmail=$(gcloud iam service-accounts list --project=$projectId --filter=$newServiceAccount --format="value(email)")

gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/serviceusage.serviceUsageViewer"
gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/iam.roleViewer"
gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/iam.serviceAccountCreator"
# new as of 1.13, validation does region listing that fails without this IAM role
gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/compute.viewer"

# was not asked for in 1.4 docs, but am having problems with back-off pulling image during admin cluster creation so trying this additional role
gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/storage.objectViewer"
