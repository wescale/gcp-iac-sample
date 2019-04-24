#!/bin/bash

workspace=$1

if [ -z "$workspace" ]
then
    workspace="default"
fi

echo "Create $workspace plateform... layer-data"

REGION="europe-west3"
GCP_PROJECT="slavayssiere-sandbox"
DB_VERSION="MYSQL_5_6"
USER_PASS="testme"
# UNIQUE_ID=$(openssl rand -base64 9  | tr -d -c ".[:alnum:]" | tr [A-Z] [a-z])
UNIQUE_ID="elupuwdoet8"

terraform workspace select $workspace
terraform apply \
    --var "region=$REGION" \
    --var "database_version=$DB_VERSION" \
    --var "gcp-project=$GCP_PROJECT" \
    --var "user2_password=$USER_PASS" \
    --var "user1_password=$USER_PASS" \
    --var "unique_id=$UNIQUE_ID" \
    --var "env=prod"
