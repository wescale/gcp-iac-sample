#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... layer-data"

REGION="europe-west3"
GCP_PROJECT="livingpackets-sandbox"
DB_VERSION="MYSQL_5_6"

terraform workspace select $workspace
terraform apply \
    --var "region=$REGION" \
    --var "database_version=$DB_VERSION" \
    --var "gcp-project=$GCP_PROJECT"
