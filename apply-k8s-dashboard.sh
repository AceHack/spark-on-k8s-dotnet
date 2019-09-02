#!/bin/bash

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta4/aio/deploy/recommended.yaml
TOKEN=$(kubectl -n kube-system describe secret default | grep -E '^token' | cut -f2 -d':' | tr -d " ")
CONTEXT=$(kubectl config current-context)
kubectl config set-credentials ${CONTEXT} --token="${TOKEN}"
