#!/bin/bash

# list current service accounts
gcloud iam service-accounts list

# create service account
newServiceAccount="anthos-allowlisted"
gcloud iam service-accounts create $newServiceAccount --display-name <span class="pl-s"><span class="pl-pds">"anthos allowlisted</span><span class="pl-pds">"</span></span> --project=<span class="pl-smi">$projectId

# wait for service account to be fully consistent
sleep 45
# get email address form
accountEmail=<span class="pl-s"><span class="pl-pds">$(</span>gcloud iam service-accounts list --project=$projectId --filter=$newServiceAccount --format=<span class="pl-pds">"</span>value(email)<span class="pl-pds">"</span><span class="pl-pds">)

# download key
gcloud iam service-accounts keys create $newServiceAccount-$projectId.json --iam-account $accountEmail

# path used in admin-ws-config.yml
realpath $newServiceAccount.json

