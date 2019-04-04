#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... kubernetes step"

kubectl apply -f kubernetes/test/app.yaml

username=$(gcloud config get-value account)
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$username

kubectl apply -f kubernetes/helm/rbac.yaml
helm init --service-account tiller

