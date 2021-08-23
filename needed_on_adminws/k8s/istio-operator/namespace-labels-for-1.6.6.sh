#!/bin/bash

kubectl get namespace -L istio-injection
kubectl label namespace istio-operator istio-injection=disabled --overwrite=true
kubectl label namespace default istio-injection=enabled --overwrite=true
 
# empty for 1.6, used in newer istio versions
kubectl get namespace -L istio.io/rev
