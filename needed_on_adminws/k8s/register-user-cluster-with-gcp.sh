#!/bin/bash

kubectl get pods -n gke-connect

echo add cluster role
kubectl apply -f cloud-console-reader.yaml

echo create service account
KSA_NAME=remote-cloud-console-reader
kubectl create serviceaccount ${KSA_NAME}

echo do role bindings to k8s service account
kubectl create clusterrolebinding VIEW_BINDING_NAME --clusterrole view --serviceaccount default:${KSA_NAME}
kubectl create clusterrolebinding CLOUD_CONSOLE_READER_BINDING_NAME --clusterrole cloud-console-reader --serviceaccount default:${KSA_NAME}

echo get secret token
SECRET_NAME=$(kubectl get serviceaccount $KSA_NAME -o jsonpath='{$.secrets[0].name}')
# get decoded token
echo ""
kubectl get secret ${SECRET_NAME} -o jsonpath='{$.data.token}' | base64 --decode
echo ""

