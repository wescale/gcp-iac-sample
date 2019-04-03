#!/bin/bash

workspace=$1

if [ -z "$var" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... layer-kubernetes"

REGION="europe-west3"
MYIP=$(curl ifconfig.me)
GCP_PROJECT="livingpackets-sandbox"

terraform workspace select $workspace
terraform apply \
    --var "region=$REGION" \
    --var "myip=$MYIP" \
    --var "gcp-project=$GCP_PROJECT"
