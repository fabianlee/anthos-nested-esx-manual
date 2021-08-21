#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "Usage: gcpProjectname"
  echo "Example: fabianleeorg"
  exit 1
fi

export project="$1"
gcloud auth login

gcloud projects list

# get project id
export projectId=$(gcloud projects list --filter="name=$project" --format='value(project_id)')
echo selected project $project id is $projectId

# set project
gcloud config set project $projectId
