#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... kubernetes step"

gcloud beta container clusters get-credentials lp-cluster-$workspace \
    --region europe-west3 \
    --project livingpackets-sandbox

kubectl apply -f test/app.yaml

username=$(gcloud config get-value account)
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$username

kubectl apply -f helm/rbac.yaml
helm init --service-account tiller

