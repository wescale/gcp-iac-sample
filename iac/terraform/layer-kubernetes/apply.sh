#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... layer-kubernetes"

REGION="europe-west3"
MYIP=$(curl ifconfig.me)
MYIP="$MYIP/32"
GCP_PROJECT="slavayssiere-sandbox"

terraform workspace select $workspace
terraform apply \
    --var "region=$REGION" \
    --var "myip=$MYIP" \
    --var "gcp-project=$GCP_PROJECT"

./apply_post.sh $workspace $GCP_PROJECT