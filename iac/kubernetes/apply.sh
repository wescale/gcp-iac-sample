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

helm repo add incubator http://storage.googleapis.com/kubernetes-charts-incubator
helm repo add elastic https://helm.elastic.co

test_tiller=$(test_tiller_present)
while [ $test_tiller -lt 1 ]; do
    echo "Wait for Tiller: $test_tiller"
    test_tiller=$(test_tiller_present)
    sleep 1
done

sleep 10


## Jaeger
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing_v1_jaeger_crd.yaml # (2)
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml

test=$(helm status elasticsearch)
if [ $? -ne 0 ]; then
    helm install incubator/elasticsearch \
        --name elasticsearch \
        --namespace monitoring \
        -f kubernetes/jaeger/values-elasticsearch.yaml
else
    echo "Elasticsearch operator already install"
fi

kubectl apply -f kubernetes/jaeger/jaeger.yaml


