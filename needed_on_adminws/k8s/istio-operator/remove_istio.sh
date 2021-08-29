#!/bin/bash
#
# removes revision of istio control plan
# and optionally the iop and entire istio namespaces
#

if [ $# -lt 1 ]; then
  echo "Usage: <istioVersion> <istio-revision>"
  echo "Example: 1.7.5 1-7-5"
  exit 1
fi

istiover="$1"
istiorev="$2"
revision_hyphenated=${istiorev//\./\-}


if [ -z "$revision_hyphenated" ]; then
  read -p "WARN: You have not specified a revision.  Are you sure you want to delete version $istiover on the default (y/N)?" answer
  if [ $answer != "y" ]; then
    exit 3
  fi
fi


# convert dotted version to hypenated version label
echo "istio version $istiover with revision $revision_hyphenated"

echo remove auto sidecar injection in default namespace
kubectl label namespace default istio.io/rev-
kubectl label namespace default istio-injection-
kubectl get namespace -L istio.io/rev

echo do rolling restart of deployment and wait for ready
kubectl rollout restart -n default deployment/my-istio-deployment
kubectl rollout status deployment my-istio-deployment
kubectl get pods -lapp=my-istio-deployment

echo make sure mutatingwebhook is delete
if [ -n "$revision_hyphenated" ]; then
  kubectl delete mutatingwebhookconfiguration/istio-sidecar-injector-${revision_hyphenated}
else
  kubectl delete mutatingwebhookconfiguration/istio-sidecar-injector
fi

echo remove control plane for istio $istiover revision $revision_hyphenated
if [ -n "$revision_hyphenated" ]; then
  if [[ "$istiover" < "1.7" ]]; then
    echo "istio versions less than 1.7 do not have --revision flag, so just doing 'istioctl x uninstall'"
    ../istio-$istiover/bin/istioctl operator remove
  else
    ../istio-$istiover/bin/istioctl x uninstall --revision $revision_hyphenated
  fi
else
  ../istio-$istiover/bin/istioctl x uninstall
fi


kubectl get -n istio-system iop
read -p "Delete the iop (y/N)?" answer
if [ $answer == "y" ]; then

  timeout 90s kubectl delete -n istio-system iop/istio-control-plane
  if [ $? -eq 0 ]; then
    echo "iop deleted normally"
  else
    echo "iop not deleted normally after waiting 90 seconds, going to empty metadata.finalizers list"
    kubectl get istiooperator.install.istio.io/istio-control-plane -n istio-system -o json | jq '.metadata.finalizers = []' | kubectl replace -f -
    sleep 5
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

      echo "waiting 20sec to see if patching with empty finalizers worked"
      sleep 20

      kubectl get ns $ns
      if [ $? -ne 0 ]; then
        echo "Using raw patch of empty finalizers to try to delete ns $ns"

        # if you really cannot get ns deleted
        # https://stackoverflow.com/questions/52369247/namespace-stuck-as-terminating-how-do-i-remove-it
        kubectl get namespace $ns -o json \
        | tr -d "\n" | sed "s/\"finalizers\": \[[^]]\+\]/\"finalizers\": []/" \
        | kubectl replace --raw /api/v1/namespaces/$ns/finalize -f -

      fi

    else
      echo "ns $ns deleted normally"
    fi

  done

fi



