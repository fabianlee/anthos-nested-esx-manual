#!/bin/bash

kubectl label namespace istio-operator istio-injection=disabled --overwrite=true
kubectl label namespace default istio-injection=enabled --overwrite=true
kubectl get namespace -L istio-injection
 
# will be empty for 1.6, only used in newer istio versions
kubectl get namespace -L istio.io/rev
