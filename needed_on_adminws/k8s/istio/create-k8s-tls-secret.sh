#!/bin/bash

echo delete secret if it exists
kubectl delete -n gke-system secret ingressgateway-wildcard-certs

echo create istio TLS secret in gke-system namespace
kubectl create -n gke-system secret tls ingressgateway-wildcard-certs --key=anthos.home.lab.key --cert=anthos.home.lab.pem

