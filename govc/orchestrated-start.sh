#!/bin/bash

echo wait for esx to be available
./start-vcenter-from-esxi.sh

echo wait for vcenter to be ready so admin cluster can be started
./start-admincluster.sh

echo waiting 60 seconds....
sleep 60

echo wait for vcenter to be ready so user cluster can be started
./start-usercluster.sh

echo wait for healthy status on admin and user cluster
./is_admin_and_user_cluster_ready.sh
