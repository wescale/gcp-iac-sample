#!/bin/bash

name=$1
region=$2

status=$(gcloud container clusters describe $name --region=$region --format="value(status)")

if [ $? -eq 0 ]; then
    echo "Cluster already created, status: $status" 
    while [ "$status" != "RUNNING" ]
    do
        sleep 5
        status=$(gcloud container clusters describe $name --region=$region --format="value(status)")
        echo "Cluster new status: $status" 
    done
else
    echo "Cluster not exist..."
fi
