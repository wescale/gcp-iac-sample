#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... layer-base"

REGION="europe-west3"
GCP_PROJECT="livingpackets-sandbox"

terraform workspace select $workspace
terraform apply \
    --var "region=$REGION" \
    --var "gcp-project=$GCP_PROJECT"
