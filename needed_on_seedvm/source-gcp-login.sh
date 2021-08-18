#!/bin/bash

export project=fabianleeorg
gcloud auth login fabian.lee@gmail.com

# get project id
export projectId=$(gcloud projects list --filter="name=$project" --format='value(project_id)')

# set project
gcloud config set project $projectId
