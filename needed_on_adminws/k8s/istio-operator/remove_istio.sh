#!/bin/bash

if [ $# -lt 1 ]; then
  echo "Usage: <istioVersion>"
  echo "Example: 1.7.5"
  exit 1
fi

istiover="$1"

# convert dotted version to hypenated version label
revision_hyphenated=${istiover//\./\-}
echo "istio version $istiover with revision $revision_hyphenated"

echo remove auto sidecar injection in default namespace
kubectl label namespace default istio.io/rev-
kubectl get namespace -L istio.io/rev

echo do rolling restart of deployment and wait for ready
kubectl rollout restart -n default deployment/my-istio-deployment
kubectl rollout status deployment my-istio-deployment
kubectl get pods -lapp=my-istio-deployment

echo remove control plan for istio $istiover
../istio-$istiover/bin/istioctl x uninstall --revision $revision_hyphenated

echo make sure mutatingwebhook is delete
kubectl delete mutatingwebhookconfiguration/istio-sidecar-injector-${revision_hyphenated}

kubectl get -n istio-system iop
read -p "Delete the iop (y/N)?" answer
if [ $answer == "y" ]; then

  timeout 90s kubectl delete -n istio-system iop/istio-control-plane
  if [ $? -eq 0 ]; then
    echo "iop deleted normally"
  else
    echo "iop not deleted normally afte waiting 90 seconds, going to empty metadata.finalizers list"
    kubectl get istiooperator.install.istio.io/istio-control-plane -n istio-system -o json | jq '.metadata.finalizers = []' | kubectl replace -f -
  fi

fi
kubectl get -n istio-system iop

# remove all istio related namespaces
kubectl get ns
read -p "Delete the istio-system and istio-operator namespaces completely (y/N)?" answer
if [ $answer == "y" ]; then

  for ns in istio-system istio-operator; do 
    echo deleting namespace
    timeout 60s kubectl delete ns $ns
    if [ $? -ne 0 ]; then
      echo "ns $ns could not be deleted normally, emptying its finalizers"
      kubectl patch ns $ns -p '{"metadata":{"finalizers":null}}'
    fi
  done

fi



