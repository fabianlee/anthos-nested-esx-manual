#!/bin/bash
#
# find all objects
# https://github.com/kubernetes/kubernetes/issues/77086
#

kubectl api-resources --verbs=list --namespaced -o name | xargs -n 1 kubectl get --show-kind --ignore-not-found -n default
