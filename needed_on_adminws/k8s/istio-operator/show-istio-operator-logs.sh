#!/bin/bash

kubectl logs --since=5m -f -n istio-operator $(kubectl get pods -n istio-operator -lname=istio-operator -o jsonpath='{.items[0].metadata.name}')
