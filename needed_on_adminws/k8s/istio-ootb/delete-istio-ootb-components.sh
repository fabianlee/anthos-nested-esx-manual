#!/bin/bash

kubectl get all -n gke-system

# show horizontal pod autoscalers
kubectl get hpa -n gke-system

# delete hpa
kubectl delete hpa/istio-ingress-hpa -n gke-system
kubectl delete hpa/istio-pilot-hpa -n gke-system

sleep 10

# show pod disruption budgets
kubectl get pdb -n gke-system

# delete pdb
kubectl delete pdb/istio-ingress -n gke-system
kubectl delete pdb/istio-pilor -n gke-system

sleep 10

# delete deployments
kubectl delete deployment/istio-pilot -n gke-system
kubectl delete deployment/istio-ingress -n gke-system

sleep 10

# delete services
kubectl delete service/istio-pilot -n gke-system
kubectl delete service/istio-ingress -n gke-system

sleep 10

# show components now
kubectl get all -n gke-system

# show secrets
kubectl get secrets -n gke-system
# show service account which use secrets
kubectl get sa -n gke-system

# delete service accounts
kubectl delete sa/istio-ingressgateway-service-account -n gke-system
kubectl delete sa/istio-pilot-service-account -n gke-system

sleep 10

# now delete all secrets starting with 'istio'
for name in $(kubectl get secrets -n gke-system -o=jsonpath="{.items[*].metadata.name}"); do [[ $name != istio* ]] || kubectl delete secret/$name -n gke-system; done

# show secrets
kubectl get secrets -n gke-system

sleep 10

# delete namespace, if it gets stuck empty the finalizers array of the namespace
kubectl delete ns gke-system
