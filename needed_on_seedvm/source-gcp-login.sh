#!/bin/bash

if [[ $# -lt 1 ]]; then
  echo "Usage: gcpProjectname"
  echo "Example: fabianleeorg"
  # do not exit a source script, it kills the session
  return
fi

export project="$1"

# logged in?
gcloud projects list >/dev/null 2>&1
[ $? -eq 0 ] || DISPLAY=":0" gcloud auth login --no-launch-browser

gcloud projects list

# get project id
export projectId=$(gcloud projects list --filter="name=$project" --format="value(project_id)")
echo selected project $project id is $projectId

# set project
gcloud config set project $projectId
