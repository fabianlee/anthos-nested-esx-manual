#!/bin/bash

# deprecate older label of 'istio-injection' by removing
for ns in default istio-system istio-operator; do
  kubectl label namespace $ns istio-injection-
done
kubectl get namespace -L istio-injection
 
# default and istio-operator should have 'istio.io/rev=1-6-6'
for ns in default istio-operator; do
  kubectl label namespace $ns istio.io/rev=1-6-6 --overwrite=true
done
kubectl get namespace -L istio.io/rev
