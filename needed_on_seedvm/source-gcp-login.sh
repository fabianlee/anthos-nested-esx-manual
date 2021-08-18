#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "Usage: gcpProjectname"
  echo "Example: fabianleeorg"
  exit 1
fi

export project="$1"
gcloud auth login

# get project id
export projectId=$(gcloud projects list --filter="name=$project" --format='value(project_id)')

# set project
gcloud config set project $projectId
