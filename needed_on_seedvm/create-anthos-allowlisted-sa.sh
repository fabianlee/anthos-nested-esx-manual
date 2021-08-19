#!/bin/bash

set -ex

# list current service accounts
gcloud iam service-accounts list

# create service account
newServiceAccount="anthos-allowlisted"
gcloud iam service-accounts create $newServiceAccount --display-name "anthos allowlisted" --project=$projectId

# wait for service account to be fully consistent
sleep 45
# get email address form
accountEmail=$(gcloud iam service-accounts list --project=$projectId --filter=$newServiceAccount --format="value(email)")

# download key
gcloud iam service-accounts keys create $newServiceAccount.json --iam-account $accountEmail

# path used in admin-ws-config.yml
realpath $newServiceAccount.json

