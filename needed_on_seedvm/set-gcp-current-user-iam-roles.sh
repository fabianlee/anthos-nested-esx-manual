#!/bin/bash

gcpUser=$(gcloud config get-value account)
echo adding service account permissions to $gcpUser

gcloud projects add-iam-policy-binding $projectId --member="user:${gcpUser}" --role="roles/resourcemanager.projectIamAdmin"

gcloud projects add-iam-policy-binding $projectId --member="user:${gcpUser}" --role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding $projectId --member="user:${gcpUser}" --role="roles/iam.serviceAccountCreator"

gcloud projects add-iam-policy-binding $projectId --member="user:${gcpUser}" --role="roles/iam.serviceAccountKeyAdmin"
