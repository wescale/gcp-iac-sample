#!/bin/bash


workspace=$1
version_chart=$2
version_app=$3

# Traefik IC
test=$(helm status public-ic)
if [ $? -ne 0 ]; then
    helm install stable/traefik \
        --name public-ic \
        --namespace ingress-controller \
        -f kubernetes/traefik/values-public.yaml \
        --set imageTag=$version_app \
        --set dashboard.domain=public-ic.$workspace.gcp-wescale.slavayssiere.fr

    kubectl -n ingress-controller annotate deploy public-ic-traefik "sidecar.jaegertracing.io/inject=true"

    kubectl apply -f kubernetes/traefik/service-monitor-public.yaml
else
    echo "Public ingress already install"
fi

test=$(helm status private-ic)
if [ $? -ne 0 ]; then
    helm install stable/traefik \
        --name private-ic \
        --namespace ingress-controller \
        -f kubernetes/traefik/values-private.yaml \
        --set imageTag=$version_app \
        --set dashboard.domain=private-ic.$workspace.gcp-wescale.slavayssiere.fr

    kubectl -n ingress-controller annotate deploy private-ic-traefik "sidecar.jaegertracing.io/inject=true"

    kubectl apply -f kubernetes/traefik/service-monitor-private.yaml
else
    echo "Private ingress already install"
fi