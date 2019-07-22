#!/bin/bash

test_tiller_present() {
  kubectl get pod -n kube-system -l app=helm,name=tiller | grep Running | wc -l | tr -d ' '
}

test_kube_db_present() {
  kubectl get crd elasticsearches.kubedb.com
}


test_jaeger_present() {
  kubectl get crd jaegers.jaegertracing.io
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
helm repo add appscode https://charts.appscode.com/stable/

helm repo update

test_tiller=$(test_tiller_present)
test_tiller_state=false
while [ $test_tiller -lt 1 ]; do
    test_tiller_state=true
    echo "Wait for Tiller: $test_tiller"
    test_tiller=$(test_tiller_present)
    sleep 1
done

if [ "$test_tiller_state" = true ] ; then
    sleep 5
fi

helm install appscode/kubedb \
  --name kubedb-operator \
  --version 0.12.0 \
  --namespace kube-system \
  --values kubernetes/kube-db/values-kubedb.yaml

## Jaeger
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/crds/jaegertracing_v1_jaeger_crd.yaml # (2)
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/service_account.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/role_binding.yaml
kubectl apply -f https://raw.githubusercontent.com/jaegertracing/jaeger-operator/master/deploy/operator.yaml

# test=$(helm status elasticsearch)
# if [ $? -ne 0 ]; then
#     helm install incubator/elasticsearch \
#         --name elasticsearch \
#         --namespace monitoring \
#         -f kubernetes/jaeger/values-elasticsearch.yaml
# else
#     echo "Elasticsearch already install"
# fi

until test_kube_db_present; do
    echo "Wait for KubeDB: $test_kubedb"
    sleep 1
done

helm install appscode/kubedb-catalog --name kubedb-catalog --version 0.12.0 \
  --namespace kube-system

until test_jaeger_present; do
    echo "Wait for Jaeger: $test_jaeger"
    sleep 1
done

kubectl apply -f kubernetes/jaeger/elasticsearch-kubedb.yaml
kubectl apply -f kubernetes/jaeger/jaeger.yaml

# kubectl delete -f kubernetes/jaeger/jaeger.yaml

# helm install --name chaos-day stable/chaoskube -f kubernetes/chaos/values-monkey.yaml

