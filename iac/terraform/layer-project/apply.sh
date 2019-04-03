#!/bin/bash

REGION="europe-west3"
GCP_PROJECT="livingpackets-sandbox"

terraform apply \
    --var "region=$REGION" \
    --var "gcp-project=$GCP_PROJECT"
