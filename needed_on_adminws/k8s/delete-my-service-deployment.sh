#!/bin/bash

echo deleting my-service and my-deployment
kubectl delete service my-service
kubectl delete deployment my-deployment

echo sleeping for 20 seconds waiting for deletion to happen...
sleep 20

# show they have been deleted
kubectl get services
kubectl get deployments
