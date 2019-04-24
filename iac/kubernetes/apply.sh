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

# ETCD Operator
helm install stable/etcd-operator --name etcd-operator --namespace ingress-controller -f kubernetes/etcd-operator/values.yaml
kubectl apply -f kubernetes/etcd-operator/cluster.yaml

# Traefik IC
helm install stable/traefik --name public-ic --namespace ingress-controller -f kubernetes/traefik/values-public.yaml --set imageTag=1.7.9
# helm install stable/traefik --name public-ic --namespace ingress-controller -f traefik/values-private.yaml

