#!/bin/bash
#
# removes revision of istio control plan
# and optionally the iop and entire istio namespaces
#

if [ $# -lt 1 ]; then
  echo "Usage: <istioVersion>"
  echo "Example: 1.7.5"
  exit 1
fi

istiover="$1"
revision_hyphenated=${istiover//\./\-}

# convert dotted version to hypenated version label
echo "istio version $istiover with revision $revision_hyphenated"

echo updating iop up to $revision_hyphenated
set -x
kubectl patch -n istio-system --type merge iop/istio-control-plane -p "{\"spec\":{\"revision\":\"$revision_hyphenated\"}}"
set +x

echo waiting 10 seconds...
sleep 10

kubectl get -n istio-system iop
