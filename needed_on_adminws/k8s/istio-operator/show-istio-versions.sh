#!/bin/bash

set -x
echo "*********************************"
kubectl get deployments -n istio-operator
kubectl describe deployments -n istio-operator | grep 'operator.istio.io/version'
#kubectl describe deployments -n istio-operator | grep '^Labels:' -C10

echo "*********************************"
kubectl get -n istio-system iop

echo "*********************************"
kubectl get mutatingwebhookconfiguration

echo "*********************************"
kubectl get -n istio-system deployment/istio-ingressgateway
kubectl describe -n istio-system deployment/istio-ingressgateway | grep 'operator.istio.io/version'

echo "*********************************"
kubectl get namespace -L istio.io/rev

echo "*********************************"
kubectl get services -n istio-system

echo "*********************************"
kubectl describe pod -lapp=my-istio-deployment | grep 'Image:' | grep proxyv2 | uniq
