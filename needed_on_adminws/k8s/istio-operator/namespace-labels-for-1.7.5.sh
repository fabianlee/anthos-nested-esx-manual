#!/bin/bash

# if this old label is set on default namespace, envoy injection will not work because this classic label conflicts with istio.io/rev below
kubectl label namespace default istio-injection-
kubectl label namespace istio-system istio-injection=disabled --overwrite=true
kubectl label namespace istio-operator istio-injection=disabled --overwrite=true
kubectl get namespace -L istio-injection
 
# default and istio-operator should have '1-7-5'
kubectl label namespace default istio.io/rev=1-7-5 --overwrite=true
kubectl label namespace istio-operator istio.io/rev=1-7-5 --overwrite=true
kubectl get namespace -L istio.io/rev
