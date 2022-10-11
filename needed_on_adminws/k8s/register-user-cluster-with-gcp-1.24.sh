#!/bin/bash
# https://kubernetes.io/docs/concepts/configuration/secret/#service-account-token-secrets
# starting in Kubernets 1.24, you must manually create the secret for the service accounts
#

kubectl get pods -n gke-connect

echo add cluster role
kubectl apply -f cloud-console-reader.yaml


echo create service account
KSA_NAME=remote-cloud-console-reader
kubectl create serviceaccount ${KSA_NAME}

echo add secret for $KSA_NAME
kubectl apply -f cloud-console-reader-secret.yaml

echo do role bindings to k8s service account
kubectl create clusterrolebinding VIEW_BINDING_NAME --clusterrole view --serviceaccount default:${KSA_NAME}
kubectl create clusterrolebinding CLOUD_CONSOLE_READER_BINDING_NAME --clusterrole cloud-console-reader --serviceaccount default:${KSA_NAME}

echo get secret token
echo ""
kubectl get secret cloud-console-reader-secret -o jsonpath='{.data.token}' | base64 --decode
echo ""

