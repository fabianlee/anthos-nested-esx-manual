#!/bin/bash

# enable GCP services required for Anthos on-prem
gcloud services enable anthos.googleapis.com anthosgke.googleapis.com cloudresourcemanager.googleapis.com container.googleapis.com gkeconnect.googleapis.com gkehub.googleapis.com serviceusage.googleapis.com stackdriver.googleapis.com monitoring.googleapis.com logging.googleapis.com

# was not asked for in 1.4 docs, but am having problems
# with image back-off pulling image
# during admin cluster creation so trying
gcloud services enable containerregistry.googleapis.com
