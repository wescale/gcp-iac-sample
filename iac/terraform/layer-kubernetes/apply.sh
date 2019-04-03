#!/bin/bash

REGION="europe-west3"
MYIP=$(curl ifconfig.me)
GCP_PROJECT="livingpackets-sandbox"

terraform apply \
    --var "region=$REGION" \
    --var "myip=$MYIP" \
    --var "gcp-project=$GCP_PROJECT"
