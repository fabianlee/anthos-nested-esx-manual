#!/bin/bash

gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/serviceusage.serviceUsageViewer"

gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/iam.serviceAccountCreator"

gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/iam.roleViewer"

# was not asked for in 1.4 docs, but am having problems with back-off pulling image during admin cluster creation so trying

gcloud projects add-iam-policy-binding $projectId --member "serviceAccount:$accountEmail" --role "roles/storage.objectViewer"
