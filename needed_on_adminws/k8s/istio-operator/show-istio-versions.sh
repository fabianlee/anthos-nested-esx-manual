#!/bin/bash

set -ex
echo "*********************************"
kubectl get deployments -n istio-operator

echo "*********************************"
kubectl get -n istio-system iop

echo "*********************************"
kubectl get mutatingwebhookconfiguration

echo "*********************************"
kubectl describe -n istio-system deployment/istio-ingressgateway | grep Labels -A10

echo "*********************************"
kubectl get namespace -L istio.io/rev

echo "*********************************"
kubectl get services -n istio-system
