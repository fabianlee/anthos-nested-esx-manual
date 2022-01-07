#!/bin/bash

echo "show entities..."
kubectl get all -n gke-system
# show horizontal pod autoscalers
kubectl get hpa -n gke-system

echo "delete hpa..."
kubectl delete hpa/istio-ingress-hpa -n gke-system
kubectl delete hpa/istio-pilot-hpa -n gke-system

sleep 10

# show pod disruption budgets
kubectl get pdb -n gke-system

echo "delete pdb..."
kubectl delete pdb/istio-ingress -n gke-system
kubectl delete pdb/istio-pilot -n gke-system

sleep 10

echo "delete deployments..."
kubectl delete deployment/istio-pilot -n gke-system
kubectl delete deployment/istio-ingress -n gke-system

sleep 10

echo "delete services..."
kubectl delete service/istio-pilot -n gke-system
kubectl delete service/istio-ingress -n gke-system

sleep 10

echo "show components now..."
kubectl get all -n gke-system

echo "show secrets and sa..."
kubectl get secrets -n gke-system
# show service account which use secrets
kubectl get sa -n gke-system

echo "delete service accounts..."
kubectl delete sa/istio-ingressgateway-service-account -n gke-system
kubectl delete sa/istio-pilot-service-account -n gke-system

sleep 10

echo "now delete all secrets starting with 'istio'..."
for name in $(kubectl get secrets -n gke-system -o=jsonpath="{.items[*].metadata.name}"); do [[ $name != istio* ]] || kubectl delete secret/$name -n gke-system; done

echo "show secrets"
kubectl get secrets -n gke-system

sleep 10

echo "delete namespace, if it gets stuck empty the finalizers array of the namespace..."
kubectl delete ns gke-system
