#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... kubernetes step"

kubectl apply -f kubernetes/test/app.yaml

kubectl apply -f kubernetes/helm/rbac.yaml
helm init --service-account tiller

