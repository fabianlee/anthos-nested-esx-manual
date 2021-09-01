#!/bin/bash
#
# delete istio objects in non-revision istio operator

ns=istio-operator

set -x

# delete deployments
kubectl delete deployment/istio-operator -n $ns

sleep 10

# delete services
kubectl delete service/istio-operator -n $ns

# show components now
kubectl get all -n $ns

