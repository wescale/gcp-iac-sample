#!/bin/bash

workspace=$1
version_chart=$2

# Consul
test=$(helm status ingress-consul)
if [ $? -ne 0 ]; then
    helm install stable/consul \
        --name ingress-consul \
        --namespace ingress-controller \
        -f kubernetes/consul/values.yaml \
        --set uiIngress.hosts={"consul.$workspace.gcp-wescale.slavayssiere.fr"}

    kubectl -n ingress-controller annotate ing ingress-consul-ui "kubernetes.io/ingress.class=private-ingress"
    kubectl -n ingress-controller patch ing ingress-consul-ui --type='json' -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/serviceName", "value":"ingress-consul"}]'
else
    echo "Consul already install"
fi