#!/bin/bash

echo delete secret if it exists
kubectl delete -n gke-system secret ingressgateway-wildcard-certs

# make sure file exists
[ -f ../istio/anthos.home.lab.key ] || { echo "ERROR did not find ../istio/anthos.home.lab.key"; exit 3; }

echo create istio TLS secret in gke-system namespace
kubectl create -n gke-system secret tls ingressgateway-wildcard-certs --key=../istio/anthos.home.lab.key --cert=../istio/anthos.home.lab.pem

