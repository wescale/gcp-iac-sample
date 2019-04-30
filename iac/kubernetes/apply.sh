#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... kubernetes step"

kubectl apply -f kubernetes/helm/rbac.yaml
helm init --service-account tiller

# ExternalDNS
# useless
# kubectl apply  -f kubernetes/external-dns/public.yaml

# ETCD operator
#kubectl apply -f https://raw.githubusercontent.com/coreos/etcd-operator/master/example/deployment.yaml
test=$(helm status ingress-etcd)
if [ $? -ne 0 ]; then
    kubectl create ns operators
    helm install stable/etcd-operator --name ingress-etcd --namespace operators -f kubernetes/etcd-operator/values.yaml
else
    echo "ECTD operator already install"
fi
kubectl apply -f kubernetes/etcd-operator/cluster.yaml

# Traefik IC
test=$(helm status public-ic)
if [ $? -ne 0 ]; then
    helm install stable/traefik \
        --name public-ic \
        --namespace ingress-controller \
        -f kubernetes/traefik/values-public.yaml \
        --set imageTag=1.7.11 \
        --set dashboard.domain=public-ic.$workspace.gcp-wescale.slavayssiere.fr

    kubectl -n ingress-controller annotate ing public-ic-traefik-dashboard "external-dns.alpha.kubernetes.io/hostname=public-ic.dev-2.gcp-wescale.slavayssiere.fr"
else
    echo "Public ingress already install"
fi

# test=$(helm status private-ic)
# if [ $? -ne 0 ]; then
#     helm install stable/traefik \
#         --name private-ic \
#         --namespace ingress-controller \
#         -f kubernetes/traefik/values-private.yaml \
#         --set imageTag=1.7.9 \
#         --set dashboard.domain=private-ic.$workspace.gcp-wescale.slavayssiere.fr \
#         --set dashboard.ingress.annotations.external-dns.alpha.kubernetes.io/hostname=private-ic.$workspace.gcp-wescale.slavayssiere.fr
# else
#     echo "Private ingress already install"
# fi

# helm install stable/traefik --name public-ic --namespace ingress-controller -f traefik/values-private.yaml

