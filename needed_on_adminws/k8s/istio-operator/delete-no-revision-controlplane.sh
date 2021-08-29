#!/bin/bash
#
# delete istio object in non-revision control plane

ns=istio-system

set -x

# show horizontal pod autoscalers
kubectl get hpa -n $ns

# delete hpa
kubectl delete hpa/istiod -n $ns

sleep 10

# show pod disruption budgets
kubectl get pdb -n $ns

# delete pdb
kubectl delete pdb/istiod -n $ns

sleep 10

# delete deployments
kubectl delete deployment/istiod -n $ns

sleep 10

# delete services
kubectl delete service/istiod -n $ns

# delete mutatingwebhookconfiguration
kubectl delete mutatingwebhookconfiguration/istio-sidecar-injector

sleep 10

# show components now
kubectl get all -n $ns

