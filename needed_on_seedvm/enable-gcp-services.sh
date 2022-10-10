#!/bin/bash

set -ex

# enable GCP services required for Anthos on-prem
gcloud services enable \
anthos.googleapis.com \
anthosgke.googleapis.com \
cloudresourcemanager.googleapis.com \
container.googleapis.com \
gkeconnect.googleapis.com \
gkehub.googleapis.com \
serviceusage.googleapis.com \
stackdriver.googleapis.com \
monitoring.googleapis.com \
logging.googleapis.com

# was not asked for in 1.4 docs, but am having problems
# with image back-off pulling image
# during admin cluster creation so trying
gcloud services enable \
containerregistry.googleapis.com

set -x
# new requirement starting at 1.9
gcloud services enable \
opsconfigmonitoring.googleapis.com

# new requirement starting at 1.13
gcloud services enable \
connectgateway.googleapis.com

# for fleet host project, managing the lifecycle of user clusters in the google console
gcloud services enable \
iam.googleapis.com \
anthosaudit.googleapis.com \
opsconfigmonitoring.googleapis.com \
storage.googleapis.com
