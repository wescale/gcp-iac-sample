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

until test_kube_db_present; do
    echo "Wait for KubeDB: $test_kubedb"
    sleep 1
done

