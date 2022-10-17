#!/bin/bash
#
# this is not usually run because the AdminWs creation takes care of it
#

function create_service_account() {
  newServiceAccount="$1"
  roles=$2

  if gcloud iam service-accounts list | grep "${newServiceAccount}@"; then
    echo "$newServiceAccount already exists"
  else
    gcloud iam service-accounts create $newServiceAccount --display-name "connect register" --project=$projectId
    echo "wait 45 seconds for service account to be fully consistent..."
    sleep 45
  fi
  
  # get email address form
  accountEmail=$(gcloud iam service-accounts list --project=$projectId --filter=$newServiceAccount --format="value(email)")
  
  # grant policy
  for role in $roles; do
    gcloud projects add-iam-policy-binding $project_id --member="serviceAccount:${accountEmail}" --role=$role
  done
  
  # download key
  if [[ ! -f $newServiceAccount.json ]]; then
    gcloud iam service-accounts keys create $newServiceAccount.json --iam-account $accountEmail
  fi
  realpath $newServiceAccount.json

}


###### MAIN ########################################################


# list current service accounts
gcloud iam service-accounts list

project_id=$(gcloud config get project)


# create service account
create_service_account "connect-register-sa" "roles/gkehub.editor"
create_service_account "log-mon-sa" "roles/logging.logWriter roles/monitoring.metricWriter roles/stackdriver.resourceMetadata.writer roles/opsconfigmonitoring.resourceMetadata.writer roles/monitoring.dashboardEditor"


