#!/bin/bash

username=$(gcloud config get-value account)
kubectl create clusterrolebinding cluster-admin-binding --clusterrole=cluster-admin --user=$username

kubectl apply -f helm/rbac.yaml
helm init --service-account tiller
