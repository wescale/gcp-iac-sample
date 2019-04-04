#!/bin/bash

workspace=$1
region=$2
GCP_PROJECT=$3

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... kubernetes step"

gcloud beta container clusters get-credentials lp-cluster-$workspace \
    --region $region \
    --project $GCP_PROJECT