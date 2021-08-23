#!/bin/bash

ns=istio-system
secret_name=tls-credential

echo delete secret if it exists
kubectl delete -n $ns secret $secret_name

# make sure file exists
[ -f ../istio/anthos.home.lab.key ] || { echo "ERROR did not find ../istio/anthos.home.lab.key"; exit 3; }

echo create istio TLS secret $secret_key in $ns namespace
kubectl create -n $ns secret tls $secret_name --key=../istio/anthos.home.lab.key --cert=../istio/anthos.home.lab.pem

