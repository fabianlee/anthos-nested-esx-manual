#!/bin/bash

# if this old label is set on default namespace, envoy injection will not work because this classic label conflicts with istio.io/rev below
for ns in default istio-system istio-operator; do
  kubectl label namespace $ns istio-injection-
done
kubectl get namespace -L istio-injection
 
# default and istio-operator should have '1-7-5'
for ns in default istio-operator; do 
  kubectl label namespace $ns istio.io/rev=1-7-5 --overwrite=true
done
kubectl get namespace -L istio.io/rev
