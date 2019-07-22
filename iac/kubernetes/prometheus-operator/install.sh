#!/bin/bash

workspace=$1
version_chart=$2

test=$(helm status prometheus-operator)
if [ $? -ne 0 ]; then

    helm install stable/prometheus-operator \
        --name prometheus-operator \
        --namespace observability \
        --values kubernetes/prometheus-operator/values.yaml \
        --set grafana.ingress.hosts={"admin.$workspace.gcp-wescale.slavayssiere.fr"} \
        --set prometheus.ingress.hosts={"admin.$workspace.gcp-wescale.slavayssiere.fr"} \
        --set alertmanager.ingress.hosts={"admin.$workspace.gcp-wescale.slavayssiere.fr"}

    kubectl -n observability patch ing prometheus-operator-prometheus --type='json' -p='[{"op": "replace", "path": "/spec/rules/0/http/paths/0/path", "value":"/prometheus-k8s"}]'
   
    kubectl -n observability \
        create cm traefik-dashboard \
        --from-file=dashboards/traefik.json
    kubectl -n observability label cm traefik-dashboard grafana_dashboard="traefik-dashbaord"

    kubectl -n observability \
        create cm redis-dashboard \
        --from-file=dashboards/redis.json
    kubectl -n observability label cm redis-dashboard grafana_dashboard="redis-dashbaord"
else
    echo "Prometheus operator already install"
fi
