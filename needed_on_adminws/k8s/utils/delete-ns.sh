#!/bin/bash
#
# force deletion of namespace
# https://stackoverflow.com/questions/55853312/how-to-force-delete-a-kubernetes-namespace
#

kubectl get ns istio-system -o json | jq '.spec.finalizers = []' | kubectl replace --raw "/api/v1/namespaces/istio-system/finalize" -f -

# alternate way
#kubectl get ns istio-system -o json | \
#  jq '.spec.finalizers=[]' | \
#  curl -X PUT http://localhost:8001/api/v1/namespaces/istio-system/finalize -H "Content-Type: application/json" --data @-
