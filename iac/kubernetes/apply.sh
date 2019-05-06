#!/bin/bash

test_tiller_present() {
    kubectl get pod -n kube-system -l app=helm,name=tiller | grep Running | wc -l | tr -d ' '
}

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

kubectl create clusterrolebinding cluster-admin-binding \
  --clusterrole cluster-admin \
  --user "$(gcloud config get-value core/account)"

echo "Create $workspace plateform... kubernetes step"

kubectl apply -f kubernetes/helm/rbac.yaml
helm init --service-account tiller


test_tiller=$(test_tiller_present)
while [ $test_tiller -lt 1 ]; do
    echo "Wait for Tiller: $test_tiller"
    test_tiller=$(test_tiller_present)
    sleep 1
done

sleep 10

# ExternalDNS
# useless
# kubectl apply  -f kubernetes/external-dns/public.yaml

# # ETCD operator
# test=$(helm status ingress-etcd)
# if [ $? -ne 0 ]; then
#     kubectl create ns operators
#     helm install stable/etcd-operator --name ingress-etcd --namespace operators -f kubernetes/etcd-operator/values.yaml --version 0.8.3
# else
#     echo "ECTD operator already install"
# fi

# until kubectl get crd etcdclusters.etcd.database.coreos.com
# do
#     echo "wait for CRD"
#     sleep 5
# done

# kubectl apply -f kubernetes/etcd-operator/cluster.yaml

# Consul
test=$(helm status ingress-consul)
if [ $? -ne 0 ]; then
    helm install --name ingress-consul --namespace ingress-controller stable/consul -f kubernetes/consul/values.yaml --set uiIngress.hosts={"consul.$workspace.gcp-wescale.slavayssiere.fr"}
else
    echo "Consul already install"
fi

# Traefik IC
test=$(helm status public-ic)
if [ $? -ne 0 ]; then
    helm install stable/traefik \
        --name public-ic \
        --namespace ingress-controller \
        -f kubernetes/traefik/values-public.yaml \
        --set imageTag=1.7.11 \
        --set dashboard.domain=public-ic.$workspace.gcp-wescale.slavayssiere.fr

    kubectl -n ingress-controller annotate ing public-ic-traefik-dashboard "external-dns.alpha.kubernetes.io/hostname=public-ic.$workspace.gcp-wescale.slavayssiere.fr"
    kubectl -n ingress-controller patch ing ingress-consul-ui --type='json' -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/backend/serviceName", "value":"public-ic-traefik-dashboard"}]'
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

